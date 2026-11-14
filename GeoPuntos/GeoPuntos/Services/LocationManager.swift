import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let manager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var lastError: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func requestCurrentLocation() async -> CLLocation? {
        if authorizationStatus == .notDetermined {
            requestPermission()
            // wait a bit for user response
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            lastError = "Permiso de ubicación no concedido."
            return nil
        }
        manager.startUpdatingLocation()
        // poll for a fix
        for _ in 0..<20 {
            if let loc = currentLocation { 
                manager.stopUpdatingLocation()
                return loc
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
        manager.stopUpdatingLocation()
        lastError = "No se pudo obtener la ubicación."
        return nil
    }

    // MARK: - Delegate
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.currentLocation = locations.last
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.lastError = error.localizedDescription
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}