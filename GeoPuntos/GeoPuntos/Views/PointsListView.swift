import SwiftUI
import SwiftData
import CoreLocation

struct PointsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GeoPoint.createdAt, order: .reverse) private var points: [GeoPoint]

    @State private var searchText = ""
    @State private var showingAdd = false
    @State private var selectedPoint: GeoPoint?
    @State private var renamingPoint: GeoPoint?
    @State private var renameText = ""
    @State private var showRenameAlert = false

    var filteredPoints: [GeoPoint] {
        if searchText.isEmpty { return points }
        return points.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.note.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredPoints) { point in
                    NavigationLink(destination: PointDetailView(point: point)) {
                        PointRow(point: point)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            delete(point)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            renameText = point.name
                            renamingPoint = point
                            showRenameAlert = true
                        } label: {
                            Label("Renombrar", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                    .contextMenu {
                        Button {
                            renameText = point.name
                            renamingPoint = point
                            showRenameAlert = true
                        } label: {
                            Label("Renombrar", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            delete(point)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar puntos")
            .navigationTitle("GeoPuntos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddPointView()
            }
            .alert("Renombrar punto", isPresented: $showRenameAlert) {
                TextField("Nombre", text: $renameText)
                Button("Cancelar", role: .cancel) {}
                Button("Guardar") {
                    if let p = renamingPoint {
                        p.name = renameText
                        p.updatedAt = Date()
                        try? modelContext.save()
                    }
                }
            } message: {
                Text("Introduce el nuevo nombre del punto.")
            }
            .overlay {
                if points.isEmpty {
                    ContentUnavailableView(
                        "Sin puntos",
                        systemImage: "mappin.and.ellipse",
                        description: Text("Toca + para crear tu primer punto de geolocalización")
                    )
                }
            }
        }
    }

    private func delete(_ point: GeoPoint) {
        modelContext.delete(point)
        try? modelContext.save()
    }
}

struct PointRow: View {
    let point: GeoPoint

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(point.name.isEmpty ? "Sin nombre" : point.name)
                .font(.headline)
            Text(String(format: "%.5f, %.5f", point.latitude, point.longitude))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !point.note.isEmpty {
                Text(point.note)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            Text(point.createdAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}