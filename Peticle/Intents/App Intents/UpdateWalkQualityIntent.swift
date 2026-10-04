//
//  UpdateWalkQualityIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

struct UpdateWalkQualityIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("Update Walk Quality")
    static var description = IntentDescription(
        "Rate, update or change how an existing walk went (its quality), for today's or yesterday's walk. Doesn't create a walk."
    )

    @Parameter(title: "Walk")
    var dogWalkEntryEntity: DogWalkEntryEntity?

    /// A real date (date only, no time): any day in Shortcuts, and Siri AI
    /// can fill "yesterday" or "last Monday". No today/yesterday enum: App
    /// Shortcut phrases can't carry a Date, so this one has no day phrase.
    @Parameter(title: "Day", description: "The day of the walk to rate", kind: .date)
    var day: Date?

    @Parameter(title: "Walk Quality", description: "The quality rating for how the walk went")
    var walkQuality: WalkQuality?

    init() {}

    /// Rates a known walk, e.g. the one StopAndRateWalkIntent just saved.
    init(walk: DogWalkEntryEntity) {
        self.dogWalkEntryEntity = walk
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        if let day {
            let dateText = day.formatted(date: .abbreviated, time: .omitted)
            let allWalks = try await DataModelHelper.walks(on: day)

            guard !allWalks.isEmpty else {
                return .result(dialog: "There's no walk on \(dateText) 😱😱😱")
            }

            let walk: DogWalkEntry

            if allWalks.count == 1, let firstWalk = allWalks.first {
                walk = firstWalk
            } else {
                dogWalkEntryEntity = try await $dogWalkEntryEntity.requestDisambiguation(
                    among: allWalks.map { $0.entity },
                    dialog: IntentDialog("Which walk would you like to rate?")
                )

                guard let dogWalkEntryEntity,
                      let walkEntry = try await DataModelHelper.dogWalkEntry(for: dogWalkEntryEntity.id) else {
                    return .result(dialog: "There's no walk on \(dateText) 😱😱😱")
                }

                walk = walkEntry
            }

            guard let walkQuality = try await getWalkQuality() else {
                throw IntentError.noEntity
            }

            try await update(walk, with: walkQuality)

            return .result(
                dialog: "Walk quality updated to \(walkQuality.localizedName()) for your walk of \(dateText)."
            )
        } else {
            if dogWalkEntryEntity == nil {
                dogWalkEntryEntity = try await $dogWalkEntryEntity.requestValue(
                    IntentDialog("Which walk would you like to rate?")
                )
            }

            guard let dogWalkEntryEntity,
                  let dogWalkEntry = try await DataModelHelper.dogWalkEntry(for: dogWalkEntryEntity.id),
                  let walkQuality = try await getWalkQuality() else {
                throw IntentError.noEntity
            }

            try await update(dogWalkEntry, with: walkQuality)

            return .result(
                dialog: "Walk quality updated to \(walkQuality.localizedName())"
            )
        }
    }

    private func update(_ walk: DogWalkEntry, with walkQuality: WalkQuality) async throws {
        let updatedWalk = DogWalkEntry(
            dogWalkID: walk.dogWalkID,
            entryDate: walk.entryDate,
            durationInMinutes: walk.durationInMinutes,
            walkQuality: walkQuality
        )

        _ = try await DataModelHelper.modify(entryWalk: updatedWalk)
    }

    private func getWalkQuality() async throws -> WalkQuality? {
        if let walkQuality {
            return walkQuality
        } else {
            walkQuality = try await $walkQuality.requestValue(
                IntentDialog("Which value would you like to apply?")
            )
            return walkQuality
        }
    }
}
