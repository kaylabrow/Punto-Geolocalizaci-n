import Foundation
import UIKit
import CoreLocation

enum MapsProvider {
    case apple
    case google
}

struct MapsService {
    static func open(_ point: GeoPoint, in provider: MapsProvider) {
        switch provider {
        case .apple:
            openAppleMaps(point)
        case .google:
            openGoogleMaps(point)
        }
    }

    private static func openAppleMaps(_ point: GeoPoint) {
        if let url = point.mapsURLApple {
            UIApplication.shared.open(url)
        }
    }

    private static func openGoogleMaps(_ point: GeoPoint) {
        // Try native Google Maps app first
        let appURLString = "comgooglemaps://?center=\(point.latitude),\(point.longitude)&q=\(point.latitude),\(point.longitude)&zoom=16"
        if let appURL = URL(string: appURLString),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }
        // Fallback to web
        if let webURL = point.mapsURLGoogle {
            UIApplication.shared.open(webURL)
        }
    }

    static func appleMapsLink(_ point: GeoPoint) -> String {
        point.mapsURLApple?.absoluteString ?? ""
    }

    static func googleMapsLink(_ point: GeoPoint) -> String {
        point.mapsURLGoogle?.absoluteString ?? ""
    }
}