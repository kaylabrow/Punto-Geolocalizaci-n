import SwiftData
import Foundation
import CoreLocation

@Model
final class GeoPoint {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(name: String = "Nuevo punto",
         latitude: Double = 0,
         longitude: Double = 0,
         note: String = "") {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.note = note
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var mapsURLApple: URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "q", value: name)
        ]
        return components?.url
    }

    var mapsURLGoogle: URL? {
        var components = URLComponents(string: "https://www.google.com/maps/search/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: "\(latitude),\(longitude)")
        ]
        return components?.url
    }
}