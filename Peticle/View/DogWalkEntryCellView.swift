//
//  DogWalkEntryCellView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

struct DogWalkEntryCellView: View {
    var dogWalkEntry: DogWalkEntry

    var body: some View {
        GlassCard(cornerRadius: PeticleTheme.Radius.large,
                  padding: PeticleTheme.Spacing.lg,
                  interactive: true) {
            HStack(spacing: PeticleTheme.Spacing.md) {
                // The dog's face is the walk quality, so no quality text.
                Image(dogWalkEntry.walkQuality.imageAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .background(Circle().fill(.ultraThinMaterial))
                    .accessibilityLabel(Text(dogWalkEntry.walkQuality.label))

                VStack(alignment: .leading, spacing: 2) {
                    Text(dogWalkEntry.entryDate, format: .dateTime.day().month(.wide).year())
                        .font(.body.weight(.semibold))
                    Text(dogWalkEntry.entryDate, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Label("\(dogWalkEntry.durationInMinutes) min", systemImage: "clock")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DogWalkEntryCellView(dogWalkEntry:DogWalkEntry(durationInMinutes: 23,
                                                   walkQuality: .good))
        .padding()
}
