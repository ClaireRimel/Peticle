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
                  padding: PeticleTheme.Spacing.md,
                  interactive: true) {
            HStack(spacing: PeticleTheme.Spacing.md) {
                Image(dogWalkEntry.walkQuality.imageAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .background(Circle().fill(.ultraThinMaterial))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(dogWalkEntry.entryDate, style: .time)
                        .font(.body.weight(.semibold))
                    Label("\(dogWalkEntry.durationInMinutes) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Text(dogWalkEntry.walkQuality.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
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
