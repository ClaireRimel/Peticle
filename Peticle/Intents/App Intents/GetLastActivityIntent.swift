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

struct AddInteractionLatestActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Get the last activity"
    static var description = IntentDescription("Return the last activity")
    
    static var isDiscoverable: Bool = false
    
    @Parameter(title: "New Human Interaction", description: "The updated rating for human interaction")
    var humanInteraction: InteractionRating
    
    @Parameter(title: "New Dog Interaction", description: "The updated rating for dog interaction")
    var dogInteraction: InteractionRating
    
    func perform() async throws -> some ProvidesDialog {
        
        if let lastEntity = try await DataModelHelper.lastDogEntry()?.entity {
            _ = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: lastEntity.id,
                                                                         durationInMinutes: lastEntity.durationInMinutes,
                                                                         humanInteraction: humanInteraction,
                                                                         dogInteraction: dogInteraction))
            return .result(dialog: "All Good")
        } else {
            return .result(dialog: "No Last entry")
        }
    }
    
}
