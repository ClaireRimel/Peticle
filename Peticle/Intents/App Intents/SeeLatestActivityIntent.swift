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
    static var description = IntentDescription("Display the last walk, or the last walk of a given day")

    /// Without it, Siri had nowhere to put "yesterday" and always showed the
    /// latest walk. A Date lets Siri fill "yesterday", "last Monday"…
    @Parameter(title: "Day", description: "The day of the walk to show. Leave empty for the latest walk.")
    var day: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("Show the last walk of \(\.$day)")
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity> & ShowsSnippetView {
        let entry = if let day {
            try await DataModelHelper.lastWalk(on: day)
        } else {
            try await DataModelHelper.lastDogEntry()
        }
        guard let lastEntry = entry else {
            if let day {
                throw IntentError.message(String(localized: "No walk on \(day.formatted(date: .complete, time: .omitted))"))
            }
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
