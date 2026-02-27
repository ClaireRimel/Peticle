//
//  EditIntents.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

struct EditDurationIntent: AppIntent {
    static var title: LocalizedStringResource = "Edit Walk Duration"
    static var description = IntentDescription("Edit the duration of an existing dog walk entry.")

    @Parameter(title: "Walk", description: "The specific walk to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: "Duration (in minutes)", description: "The updated duration of the walk")
    var duration: Int
    
    @MainActor
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity>  {
        
        if let entry = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                                durationInMinutes: duration,
                                                                                walkQuality: walkEntity.walkQuality ?? .ok)) {
            return .result(value: entry.entity, dialog: "The duration has been updated to \(duration) minutes")
        } else {
            throw IntentError.noEntity
        }
    }
}

struct EditWalkQualityIntent: AppIntent {
    static var title: LocalizedStringResource = "Edit Walk Quality"
    static var description = IntentDescription("Edit the walk quality of an existing dog walk entry.")

    @Parameter(title: "Walk", description: "The specific walk entry to update")
    var walkEntity: DogWalkEntryEntity
    
    @Parameter(title: LocalizedStringResource("Walk Quality", comment: "The updated quality of the walk"), description: "The quality rating for how the walk went")
    var walkQuality: WalkQuality
    
    @MainActor
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
    static var title: LocalizedStringResource = "Edit walk duration then the quality"
    static var description = IntentDescription("Edit the duration then the quality of an existing dog walk entry.")

    @Parameter(title: "Walk", description: "The specific walk entry to update")
    var walkEntity: DogWalkEntryEntity

    @Parameter(title: "Duration (in minutes)", description: "The updated duration of the walk")
    var duration: Int

    @Parameter(title: LocalizedStringResource("Walk Quality", comment: "The updated quality of the walk"), description: "The quality rating for how the walk went")
    var walkQuality: WalkQuality

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let _ = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: walkEntity.id,
                                                                         durationInMinutes: duration,
                                                                         walkQuality: walkQuality))

        return .result(dialog: "Walk duration and quality updated successfully")
    }
}

// MARK: - Focus Filter

/// SetFocusFilterIntent: Adapts the app's behavior when a Focus mode activates.
/// Users can configure this in Settings > Focus to customize Peticle during dog walks.
struct DogWalkingFocus: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Dog Walking Focus"
    
    static var description: IntentDescription? = IntentDescription(
        "Configure the app\'s behavior during your dog walking Focus."
    )

    @Parameter(title: "Show only today\'s walks", default: false)
    var showOnlyTodaysWalks: Bool

    var displayRepresentation: DisplayRepresentation {
        let subtitle = showOnlyTodaysWalks ? "Showing today\'s walks only" : "Showing all walks"
        return DisplayRepresentation(
            title: "Dog Walking Mode",
            subtitle: "\(subtitle)"
        )
    }

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(showOnlyTodaysWalks, forKey: "focusFilter_showOnlyTodaysWalks")
        return .result()
    }
}
