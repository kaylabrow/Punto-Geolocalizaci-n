import SwiftUI
import SwiftData
import MapKit

struct PointDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let point: GeoPoint

    @State private var showRename = false
    @State private var renameText = ""
    @State private var showWhatsAppOptions = false
    @State private var showDeleteConfirm = false
    @State private var editNote = ""
    @State private var isEditingNote = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Map preview
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: point.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker(point.name, coordinate: point.coordinate)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text(point.name)
                        .font(.title2.bold())
                    Text(String(format: "Latitud: %.6f", point.latitude))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(String(format: "Longitud: %.6f", point.longitude))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Creado: \(point.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                if !point.note.isEmpty || isEditingNote {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nota")
                            .font(.headline)
                        if isEditingNote {
                            TextField("Nota", text: $editNote, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            HStack {
                                Button("Cancelar") { isEditingNote = false }
                                Button("Guardar") {
                                    point.note = editNote
                                    point.updatedAt = Date()
                                    try? modelContext.save()
                                    isEditingNote = false
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            Text(point.note.isEmpty ? "Sin nota" : point.note)
                                .foregroundStyle(point.note.isEmpty ? .tertiary : .primary)
                            Button("Editar nota") {
                                editNote = point.note
                                isEditingNote = true
                            }
                            .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                } else {
                    Button {
                        editNote = ""
                        isEditingNote = true
                    } label: {
                        Label("Añadir nota", systemImage: "note.text")
                    }
                    .padding(.horizontal)
                }

                // Actions
                VStack(spacing: 12) {
                    Button {
                        MapsService.open(point, in: .apple)
                    } label: {
                        Label("Abrir en Apple Maps", systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        MapsService.open(point, in: .google)
                    } label: {
                        Label("Abrir en Google Maps", systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        showWhatsAppOptions = true
                    } label: {
                        Label("Enviar por WhatsApp", systemImage: "message.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)

                    Button {
                        renameText = point.name
                        showRename = true
                    } label: {
                        Label("Renombrar", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Eliminar punto", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Enviar por WhatsApp", isPresented: $showWhatsAppOptions, titleVisibility: .visible) {
            Button("Enlace de Google Maps") {
                WhatsAppService.send(point, linkType: .google)
            }
            Button("Enlace de Apple Maps") {
                WhatsAppService.send(point, linkType: .apple)
            }
            Button("Ambos enlaces") {
                WhatsAppService.send(point, linkType: .both)
            }
            Button("Cancelar", role: .cancel) {}
        }
        .alert("Renombrar punto", isPresented: $showRename) {
            TextField("Nombre", text: $renameText)
            Button("Cancelar", role: .cancel) {}
            Button("Guardar") {
                point.name = renameText
                point.updatedAt = Date()
                try? modelContext.save()
            }
        }
        .alert("¿Eliminar este punto?", isPresented: $showDeleteConfirm) {
            Button("Eliminar", role: .destructive) {
                modelContext.delete(point)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }
}