//
//  ManageLastWalkEntryIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

/// Main intent: answers with a dialog and hands the system a live snippet.
/// Shows the latest walk, or the walk picked in Shortcuts. Picking a day
/// is UpdateWalkQualityIntent's job: no today/yesterday here, to avoid
/// two intents answering the same request.
struct ManageLatestWalkEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Last Walk Entry"
    static var description = IntentDescription(
        "Display your latest dog walk, then rate, adjust or delete it right from the card."
    )

    @Parameter(title: "Walk")
    var walkEntity: DogWalkEntryEntity?

    init() {}

    @MainActor
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity?> & ProvidesDialog & ShowsSnippetIntent {
        let walk: DogWalkEntryEntity? = if let walkEntity {
            try await DataModelHelper.dogWalkEntry(for: walkEntity.id)?.entity
        } else {
            try await DataModelHelper.lastDogEntry()?.entity
        }
        let dialog: IntentDialog = walk == nil
            ? "No walk yet!"
            : "Here is your walk. How did it go?"

        return .result(
            value: walk,
            dialog: dialog,
            snippetIntent: LatestWalkSnippetIntent(walk: walk)
        )
    }
}

// SnippetIntent: iOS 26.0
/// Renders the chosen walk. `perform()` only reads: the system re-runs it
/// after every button tap (rate, delete) to redraw the card in place.
struct LatestWalkSnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource = "Latest Walk Snippet"
    static let isDiscoverable = false

    /// The walk on the card. Re-fetched on every redraw so a new rating or
    /// duration shows up, and a deleted walk shows the empty state.
    @Parameter(title: "Walk")
    var walk: DogWalkEntryEntity?

    init() {}

    init(walk: DogWalkEntryEntity?) {
        self.walk = walk
    }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        var walkEntity: DogWalkEntryEntity?
        if let walk {
            walkEntity = try await DataModelHelper.dogWalkEntry(for: walk.id)?.entity
        }
        return .result(view: ManageLastWalkEntrySnippetView(walkEntity: walkEntity))
    }
}
