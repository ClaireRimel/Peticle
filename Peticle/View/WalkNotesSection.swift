//
//  WalkNotesSection.swift
//  Peticle
//

import SwiftUI
import SwiftData

/// Notes attached to a walk — created by Siri through the `.notes` schema.
struct WalkNotesSection: View {
    @Query private var notes: [WalkNote]
    @Environment(\.modelContext) private var modelContext

    init(walkID: UUID) {
        _notes = Query(
            filter: #Predicate<WalkNote> { $0.walkID == walkID },
            sort: \WalkNote.creationDate
        )
    }

    var body: some View {
        if !notes.isEmpty {
            GlassSection("Notes") {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(notes) { note in
                        VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xs) {
                            HStack(spacing: PeticleTheme.Spacing.xs) {
                                if note.isPinned {
                                    Image(systemName: "pin.fill")
                                        .foregroundStyle(.tint)
                                        .accessibilityLabel("Pinned")
                                }
                                Text(note.name)
                                    .font(.headline)
                            }
                            if !note.content.isEmpty {
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            if !note.photos.isEmpty {
                                NotePhotosRow(photos: note.photos)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(PeticleTheme.Spacing.lg)
                        .contentShape(.rect)
                        .contextMenu {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                delete(note)
                            }
                        }

                        if note.id != notes.last?.id {
                            Divider()
                                .padding(.leading, PeticleTheme.Spacing.lg)
                        }
                    }
                }
            }
        }
    }

    private func delete(_ note: WalkNote) {
        DataModelHelper.deindexNotes(ids: [note.noteID])
        withAnimation {
            modelContext.delete(note)
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete the note: \(error)")
            }
        }
    }
}

/// Photos Siri attached to a note, as a scrolling row of thumbnails.
private struct NotePhotosRow: View {
    let photos: [Data]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: PeticleTheme.Spacing.sm) {
                ForEach(photos.indices, id: \.self) { index in
                    if let image = UIImage(data: photos[index]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(.rect(cornerRadius: PeticleTheme.Radius.small))
                            .accessibilityLabel("Photo \(index + 1)")
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.top, PeticleTheme.Spacing.xs)
    }
}
