//
//  DeleteOrAddWalkIntent.swift
//  Peticle
//
//  Created by Claire on 06/09/2025.
//

import AppIntents
import Foundation
import CoreSpotlight
import SwiftData

struct AddWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a Quick Dog Walk"
    static var description = IntentDescription("Quickly register a new dog walk with a given duration.")
    
    @Parameter(
        title: "Duration",
        description: "The number of minutes you want to log"
    )
    var duration: Int

    @Parameter(
        title: "Walk Quality",
        description: "The quality rating for how the walk went"
    )
    var walkQuality: WalkQuality

    func perform() async throws -> some ProvidesDialog {
        let entry = try DataModelHelper.newEntry(durationInMinutes: duration,
                                         walkQuality: walkQuality)

        try? await CSSearchableIndex.default().indexAppEntities([entry.entity])

        return .result(dialog: "Added a new walk of \(duration) minute\(duration == 1 ? "" : "s").")
    }
}

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

