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

struct EditDurationThenQualityIntent: AppIntent {
    static var title: LocalizedStringResource = "Edit walk duration then the quality"
    static var description = IntentDescription("Edit the duration then the quality of an existing dog walk entry.")
    /// Overlaps UpdateWalkQualityIntent and asks for a duration: hidden so
    /// Siri doesn't pick it for "update walk quality".
    static let isDiscoverable = false

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

/// Control intent behind the quality buttons of the latest walk snippet.
/// It only does the mutation and returns: the system then re-runs
/// `LatestWalkSnippetIntent` and redraws the card in place.
struct RateWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Rate Walk"
    static let isDiscoverable = false

    @Parameter(title: "Walk")
    var walkEntity: DogWalkEntryEntity

    @Parameter(title: "Walk Quality")
    var walkQuality: WalkQuality

    init() {}

    init(walkEntity: DogWalkEntryEntity, walkQuality: WalkQuality) {
        self.walkEntity = walkEntity
        self.walkQuality = walkQuality
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        // Read the stored entry so a duration changed from the same snippet isn't overwritten
        guard let entry = try await DataModelHelper.dogWalkEntry(for: walkEntity.id) else {
            throw IntentError.noEntity
        }
        _ = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: entry.dogWalkID,
                                                                     durationInMinutes: entry.durationInMinutes,
                                                                     walkQuality: walkQuality))
        return .result()
    }
}

/// Control intent behind the −1 / +1 min buttons of the latest walk snippet.
struct AdjustWalkDurationIntent: AppIntent {
    static var title: LocalizedStringResource = "Adjust Walk Duration"
    static let isDiscoverable = false

    @Parameter(title: "Walk")
    var walkEntity: DogWalkEntryEntity

    @Parameter(title: "Minutes to add")
    var minutes: Int

    init() {}

    init(walkEntity: DogWalkEntryEntity, minutes: Int) {
        self.walkEntity = walkEntity
        self.minutes = minutes
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let entry = try await DataModelHelper.dogWalkEntry(for: walkEntity.id) else {
            throw IntentError.noEntity
        }
        _ = try await DataModelHelper.modify(entryWalk: DogWalkEntry(dogWalkID: entry.dogWalkID,
                                                                     durationInMinutes: max(0, entry.durationInMinutes + minutes),
                                                                     walkQuality: entry.walkQuality))
        return .result()
    }
}

// MARK: - Focus Filter

/// SetFocusFilterIntent: Adapts the app's behavior when a Focus mode activates.
/// Users can configure this in Settings > Focus to customize Peticle during dog walks.
struct DogWalkingFocus: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Dog Walking Focus"
    
    static var description: IntentDescription? = IntentDescription(
        "Configure the app's behavior during your dog walking Focus."
    )

    @Parameter(title: "Show only today's walks", default: false)
    var showOnlyTodaysWalks: Bool

    var displayRepresentation: DisplayRepresentation {
        let subtitle = showOnlyTodaysWalks ? "Showing today's walks only" : "Showing all walks"
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
