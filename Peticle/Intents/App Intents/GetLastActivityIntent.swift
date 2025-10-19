//
//  GetLastActivityIntent.swift
//  Peticle
//
//  Created by Claire on 27/09/2025.
//

import AppIntents

struct GetLastActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Get the last activity"
    static var description = IntentDescription("Return the last activity")
    
    static var isDiscoverable: Bool = false
    
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity?> {
        
        let lastEntry = try await DataModelHelper.lastDogEntry()
        
        return .result(value: lastEntry?.entity)
    }
}

struct AddWalkQualityLatestActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Update walk quality for last activity"
    static var description = IntentDescription("Update the walk quality of the last activity")
    
    static var isDiscoverable: Bool = false
    
    @Parameter(title: "New Walk Quality",
               description: "The quality rating for how the walk went")
    var walkQuality: WalkQuality
    
    func perform() async throws -> some ProvidesDialog {
        
        if let lastEntity = try await DataModelHelper.lastDogEntry()?.entity {
            _ = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: lastEntity.id,
                                                                         durationInMinutes: lastEntity.durationInMinutes,
                                                                         walkQuality: walkQuality))
            return .result(dialog: "Walk quality updated successfully")
        } else {
            return .result(dialog: "No last entry found")
        }
    }
    
}
