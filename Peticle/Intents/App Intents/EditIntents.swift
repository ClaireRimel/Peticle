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
                                                                                walkQuality: walkEntity.walkQuality ?? .none)) {
            return .result(value: entry.entity, dialog: "The durationhas been updated to \(duration) minutes")
        } else {
            throw IntentError.noEntity
        }
    }
}

struct EditWalkQualityIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Walk Quality"
    static var description = IntentDescription("Update the walk quality of an existing dog walk entry.")
    
    @Parameter(title: "Walk Entry", description: "The walk entry you want to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: "New Walk Quality", description: "The updated walk quality")
    var walkQuality: InteractionRating
    
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity> {
        if let entry = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                                durationInMinutes: walkEntity.durationInMinutes,
                                                                                walkQuality: walkQuality)) {
            
            return .result(value: entry.entity, dialog: "The walk quality has been updated to \(walkQuality.localizedName()).")
            
        } else {
            throw IntentError.noEntity
        }
    }
}


