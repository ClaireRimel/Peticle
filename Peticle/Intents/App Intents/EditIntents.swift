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
    
    @Parameter(title: "Walk Entry", description: "The specific walk entry to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: "Duration (in minutes)", description: "The updated duration of the walk")
    var duration: Int
    
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity>  {
        
        if let entry = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                                durationInMinutes: duration,
                                                                                walkQuality: walkEntity.walkQuality ?? .ok)) {
            return .result(value: entry.entity, dialog: "The durationhas been updated to \(duration) minutes")
        } else {
            throw IntentError.noEntity
        }
    }
}

struct EditWalkQualityIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Walk Quality"
    static var description = IntentDescription("Update the walk quality of an existing dog walk entry.")
    
    @Parameter(title: "Walk Entry", description: "The specific walk entry to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: LocalizedStringResource("walk Quality", comment: "The updated quality of the walk"), description: "The quality rating for how the walk went")
    var walkQuality: WalkQuality
    
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

struct EditDurationThenQualityIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Walk Duration"
    static var description = IntentDescription("Update the duration of an existing dog walk entry.")

    @Parameter(title: "Walk Entry", description: "The specific walk entry to update")
    var walkEntity: DogWalkEntryEntity

    @Parameter(title: "Duration (in minutes)", description: "The updated duration of the walk")
    var duration: Int

    @Parameter(title: LocalizedStringResource("walk Quality", comment: "The updated quality of the walk"), description: "The quality rating for how the walk went")
    var walkQuality: WalkQuality

    func perform() async throws -> some ProvidesDialog {
        do {
            let _ = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                             durationInMinutes: duration,
                                                                             walkQuality: walkQuality))

            return .result(dialog: "Walk duration and quality updated successfully")
        } catch {
            return .result(dialog: "Walk duration and quality updated fails")
        }
    }
}

