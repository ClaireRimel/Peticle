//
//  EditIntents.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

struct EditDurationIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Walk Duration"
    static var description = IntentDescription("Update the duration of an existing dog walk entry.")
    
    @Parameter(title: "Walk Entry", description: "The walk entry you want to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: "New Duration (in minutes)", description: "The updated duration of the walk")
    var duration: Int
    
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity>  {
        
        if let entry = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                                durationInMinutes: duration,
                                                                                humanInteraction: walkEntity.humanInteraction ?? .none,
                                                                                dogInteraction: walkEntity.dogInteraction ?? .none)) {
            return .result(value: entry.entity, dialog: "The durationhas been updated to \(duration) minutes")
        } else {
            throw IntentError.noEntity
        }
    }
}

struct EditHumainInteractionIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Human Interaction Rating"
    static var description = IntentDescription("Update the human interaction rating of an existing dog walk entry.")
    
    @Parameter(title: "Walk Entry", description: "The walk entry you want to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: "New Human Interaction", description: "The updated rating for human interaction")
    var humanInteraction: InteractionRating
    
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity> {
        if let entry = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                                durationInMinutes: walkEntity.durationInMinutes,
                                                                                humanInteraction: humanInteraction,
                                                                                dogInteraction: walkEntity.dogInteraction ?? .none)) {
            
            return .result(value: entry.entity, dialog: "The human interaction rating has been updated to \(humanInteraction.localizedName()).")
            
        } else {
            throw IntentError.noEntity
        }
    }
}

struct EditDogInterationIntent: AppIntent  {
    static var title: LocalizedStringResource = "Update Dog Interaction Rating"
    static var description = IntentDescription("Update the dog interaction rating of an existing dog walk entry.")
    
    @Parameter(title: "Walk Entry", description: "The walk entry you want to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: "New Dog Interaction", description: "The updated rating for dog interaction")
    var dogInteraction: InteractionRating
    
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity> {
        if let entry = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                                durationInMinutes: walkEntity.durationInMinutes,
                                                                                humanInteraction: walkEntity.humanInteraction ?? .none,
                                                                                dogInteraction: dogInteraction )) {
            
            return .result(value: entry.entity, dialog: "The dog interaction rating has been updated to \(dogInteraction.localizedName()).")
            
        } else {
            throw IntentError.noEntity
        }
    }
}

