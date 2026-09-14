//
//  WalkNotesSection.swift
//  Peticle
//

import SwiftUI
import SwiftData

/// Notes attached to a walk — created by Siri through the `.notes` schema.
struct WalkNotesSection: View {
    @Query private var notes: [WalkNote]

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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(PeticleTheme.Spacing.lg)

                        if note.id != notes.last?.id {
                            Divider()
                                .padding(.leading, PeticleTheme.Spacing.lg)
                        }
                    }
                }
            }
        }
    }
}
