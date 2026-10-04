//
//  NewParameterIntents.swift
//  Peticle
//
//  Two iOS 27 parameter features, one intent each:
//  @UnionValue as an input parameter, and EntityCollection.
//

import AppIntents
import SwiftUI
import SwiftData
import CoreSpotlight

// MARK: - @UnionValue as a parameter (iOS 27)

// DogOrWalk lives in Model/Enum/DogOrWalk.swift, shared with the widget.

struct ShowDogOrWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Show a Dog or a Walk"
    static var description = IntentDescription("Show one of your dogs, or one of your walks, from a single parameter.")

    @Parameter(title: "Dog or walk")
    var item: DogOrWalk

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$item.type): \(\.$item.value)")
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        switch item {
        case .dog(let dog):
            return .result(dialog: "Here is \(dog.name).", view: DogCard(dog: dog))
        case .walk(let walk):
            return .result(dialog: "Here is your walk.", view: WalkCard(walk: walk))
        }
    }
}

private struct DogCard: View {
    let dog: DogEntity

    var body: some View {
        HStack(spacing: PeticleTheme.Spacing.lg) {
            if let data = dog.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xs) {
                Text(dog.name)
                    .font(.headline)
                Text("\(dog.age) years old")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

private struct WalkCard: View {
    let walk: DogWalkEntryEntity

    var body: some View {
        let quality = walk.walkQuality ?? .ok
        HStack(spacing: PeticleTheme.Spacing.lg) {
            Image(quality.imageAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .accessibilityLabel(Text(quality.label))
            VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xs) {
                Text(walk.date.formatted(date: .long, time: .shortened))
                    .font(.headline)
                Label("\(walk.durationInMinutes) min", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - EntityCollection (iOS 27)

/// Rates many walks at once. `EntityCollection` only carries the walks'
/// identifiers: with `[DogWalkEntryEntity]`, the system would load every
/// walk before `perform()` even runs.
struct RateWalksIntent: AppIntent {
    static var title: LocalizedStringResource = "Rate Several Walks"
    static var description = IntentDescription("Give the same quality to several walks at once, e.g. the ones found by Find Dog Walks.")

    @Parameter(title: "Walks")
    var walks: EntityCollection<DogWalkEntryEntity>

    @Parameter(title: "Walk Quality")
    var walkQuality: WalkQuality

    static var parameterSummary: some ParameterSummary {
        Summary("Rate \(\.$walks) as \(\.$walkQuality)")
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        // Only the identifiers are needed: nothing is resolved.
        let count = try DataModelHelper.rateWalks(ids: walks.identifiers, as: walkQuality)
        return .result(dialog: "Rated \(count) walk\(count == 1 ? "" : "s") as \(walkQuality.localizedName()).")
    }
}

extension DataModelHelper {
    /// Rates the walks in one fetch and one save. Returns how many were found.
    static func rateWalks(ids: [UUID], as quality: WalkQuality) throws -> Int {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let walks = try modelContext.fetch(FetchDescriptor<DogWalkEntry>(predicate: #Predicate { ids.contains($0.dogWalkID) }))
        walks.forEach { $0.walkQuality = quality }
        try modelContext.save()
        index(walks.map(\.entity))
        return walks.count
    }
}
