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
        "Update the quality rating for your most recent walk from today or yesterday."
    )

    @Parameter(title: "Walk")
    var dogWalkEntryEntity: DogWalkEntryEntity?

    @Parameter(title: "Date", description: "Choose which date to update the walk quality for")
    var dateSelection: DateSelection?

    @Parameter(title: "Walk Quality", description: "The quality rating for how the walk went")
    var walkQuality: WalkQuality?

    init() {}

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        if let dateSelection {
            let dateText = dateSelection == .today ? "today" : "yesterday"
            let allWalks = try await DataModelHelper.allWalks(for: dateSelection)

            guard !allWalks.isEmpty else {
                return .result(dialog: "There's no walk \(dateText) 😱😱😱")
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
                    return .result(dialog: "There's no walk \(dateText) 😱😱😱")
                }

                walk = walkEntry
            }

            guard let walkQuality = try await getWalkQuality() else {
                throw IntentError.noEntity
            }

            try await update(walk, with: walkQuality)

            return .result(
                dialog: "Walk quality updated to \(walkQuality.localizedName()) for your \(dateText) walk."
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
