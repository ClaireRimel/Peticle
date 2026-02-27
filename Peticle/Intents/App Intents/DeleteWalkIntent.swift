//
//  DeleteWalkIntent.swift
//  Peticle
//
//  Created by Claire on 30/10/2025.
//

import AppIntents

struct DeleteWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete walk"
    static var description = IntentDescription("Remove a previously recorded walk.")

    @Parameter(
        title: "Walk",
        description: "The specific walk entry to delete"
    )
    var walkEntity: DogWalkEntryEntity

    init() {}

    init(walkEntity: DogWalkEntryEntity) {
        self.walkEntity = walkEntity
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let shouldDeleteIt = try await $walkEntity.requestConfirmation(
            for: walkEntity,
            dialog: "Are you sure you want to delete this walk?"
        )

        if shouldDeleteIt {
            try await DataModelHelper.deleteWalk(for: walkEntity.id)
        }

        return .result()
    }
}

