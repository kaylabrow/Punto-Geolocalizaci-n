import SwiftUI
import SwiftData
import CoreLocation

struct AddPointView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var note = ""
    @State private var useCurrentLocation = true
    @State private var latitudeText = ""
    @State private var longitudeText = ""
    @State private var isLocating = false
    @State private var errorMessage: String?

    @ObservedObject private var locationManager = LocationManager.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Nombre") {
                    TextField("Nombre del punto", text: $name)
                }
                Section("Nota (opcional)") {
                    TextField("Descripción", text: $note)
                }
                Section("Ubicación") {
                    Toggle("Usar mi ubicación actual", isOn: $useCurrentLocation)
                    if useCurrentLocation {
                        Button {
                            Task { await captureLocation() }
                        } label: {
                            HStack {
                                if isLocating {
                                    ProgressView()
                                } else {
                                    Image(systemName: "location.fill")
                                }
                                Text(isLocating ? "Obteniendo ubicación..." : "Actualizar ubicación actual")
                            }
                        }
                        .disabled(isLocating)
                        if let loc = locationManager.currentLocation {
                            Text(String(format: "Lat: %.6f, Lon: %.6f", loc.coordinate.latitude, loc.coordinate.longitude))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        TextField("Latitud", text: $latitudeText)
                            .keyboardType(.numbersAndPunctuation)
                        TextField("Longitud", text: $longitudeText)
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
                if let err = errorMessage {
                    Section {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("Nuevo punto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear {
                locationManager.requestPermission()
            }
        }
    }

    private var canSave: Bool {
        if useCurrentLocation {
            return locationManager.currentLocation != nil
        } else {
            return Double(latitudeText) != nil && Double(longitudeText) != nil
        }
    }

    private func captureLocation() async {
        isLocating = true
        errorMessage = nil
        let loc = await locationManager.requestCurrentLocation()
        isLocating = false
        if loc == nil {
            errorMessage = locationManager.lastError ?? "No se pudo obtener la ubicación."
        }
    }

    private func save() {
        let lat: Double
        let lon: Double
        if useCurrentLocation {
            guard let loc = locationManager.currentLocation else {
                errorMessage = "Primero obtén tu ubicación."
                return
            }
            lat = loc.coordinate.latitude
            lon = loc.coordinate.longitude
        } else {
            guard let la = Double(latitudeText), let lo = Double(longitudeText) else {
                errorMessage = "Coordenadas inválidas."
                return
            }
            lat = la
            lon = lo
        }
        let pointName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "Punto \(Date().formatted(date: .abbreviated, time: .shortened))" : name
        let point = GeoPoint(name: pointName, latitude: lat, longitude: lon, note: note)
        modelContext.insert(point)
        try? modelContext.save()
        dismiss()
    }
}