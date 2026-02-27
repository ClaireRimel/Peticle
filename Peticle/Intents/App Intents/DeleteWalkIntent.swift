//
//  DeleteWalkIntent.swift
//  Peticle
//
//  Created by Claire on 30/10/2025.
//

import AppIntents

struct DeleteWalkIntent: DeleteIntent {
    static var title: LocalizedStringResource = "Delete walk"
    static var description = IntentDescription("Remove a previously recorded walk.")

    @Parameter(
        title: "Walks",
        description: "The walk entries to delete"
    )
    var entities: [DogWalkEntryEntity]

    init() {}

    init(walkEntity: DogWalkEntryEntity) {
        self.entities = [walkEntity]
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        for entity in entities {
            try await DataModelHelper.deleteWalk(for: entity.id)
        }

        return .result()
    }
}
