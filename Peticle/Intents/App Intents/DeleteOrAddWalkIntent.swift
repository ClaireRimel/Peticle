//
//  DeleteOrAddWalkIntent.swift
//  Peticle
//
//  Created by Claire on 06/09/2025.
//

import AppIntents
import Foundation
import CoreSpotlight

struct AddWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a Quick Dog Walk"
    static var description = IntentDescription("Quickly register a new dog walk with a given duration.")
    
    @Parameter(
        title: "Duration",
        description: "The number of minutes you want to log"
    )
    var duration: DurationSelection


    @Parameter(
        title: "Walk Quality",
        description: "The quality rating for how the walk went"
    )
    var walkQuality: WalkQuality

    func perform() async throws -> some ProvidesDialog {
        let minutes = duration.minutes
        _ = try DataModelHelper.newEntry(durationInMinutes: minutes,
                                         walkQuality: walkQuality)

        return .result(dialog: "Added a new walk of \(minutes) minute\(minutes == 1 ? "" : "s").")
    }
}

struct DeleteWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete Walk Entry"
    static var description = IntentDescription("Remove a previously recorded dog walk.")
    
    @Parameter(
        title: "Walk Entry",
        description: "The specific walk entry to delete"
    )
    var walkEntity: DogWalkEntryEntity
    
    init() {}
    
    init(walkEntity: DogWalkEntryEntity) {
        self.walkEntity = walkEntity
    }
    
    func perform() async throws -> some IntentResult {
        try await DataModelHelper.deleteWalk(for: walkEntity.id)

        return .result()
    }
}

