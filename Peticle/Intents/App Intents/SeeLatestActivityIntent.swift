//
//  LatestActivityIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import SwiftUI

struct SeeLatestActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Show the last activity"
    static var description = IntentDescription("display the last activity")

    @MainActor
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity> & ShowsSnippetView {
        guard let lastEntry = try await DataModelHelper.lastDogEntry() else {
            throw IntentError.noEntity
        }

        return .result(
            value: lastEntry.entity,
            view: LatestActivitySnippetView(entry: lastEntry)
        )
    }
}

/// Static snippet: a one-time snapshot, no buttons.
private struct LatestActivitySnippetView: View {
    let entry: DogWalkEntry

    var body: some View {
        HStack(spacing: PeticleTheme.Spacing.lg) {
            Image(entry.walkQuality.imageAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xs) {
                Text(entry.entryDate.formatted(date: .long, time: .shortened))
                    .font(.headline)
                Label("\(entry.durationInMinutes) min", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(entry.walkQuality.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.peticleBrand)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}
