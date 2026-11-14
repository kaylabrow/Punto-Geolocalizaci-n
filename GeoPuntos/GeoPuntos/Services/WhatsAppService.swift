import Foundation
import UIKit

enum WhatsAppLinkType {
    case google
    case apple
    case both
}

struct WhatsAppService {
    static func send(_ point: GeoPoint, linkType: WhatsAppLinkType) {
        var message = "📍 \(point.name)\n"
        if !point.note.isEmpty {
            message += "\(point.note)\n"
        }
        message += "Lat: \(point.latitude), Lon: \(point.longitude)\n\n"
        switch linkType {
        case .google:
            message += "Abrir en Google Maps:\n\(MapsService.googleMapsLink(point))"
        case .apple:
            message += "Abrir en Apple Maps:\n\(MapsService.appleMapsLink(point))"
        case .both:
            message += "Google Maps:\n\(MapsService.googleMapsLink(point))\n\nApple Maps:\n\(MapsService.appleMapsLink(point))"
        }

        let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        // Try WhatsApp app first
        if let appURL = URL(string: "whatsapp://send?text=\(encoded)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }
        // Fallback to web
        if let webURL = URL(string: "https://wa.me/?text=\(encoded)") {
            UIApplication.shared.open(webURL)
        }
    }
}