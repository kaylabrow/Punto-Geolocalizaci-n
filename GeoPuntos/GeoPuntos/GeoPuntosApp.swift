import SwiftUI
import SwiftData

@main
struct GeoPuntosApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: GeoPoint.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}