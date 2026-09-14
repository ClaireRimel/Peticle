//
//  ManageLastWalkEntryIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

/// Main intent: answers with a dialog and hands the system a live snippet.
struct ManageLatestWalkEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Last Walk Entry"
    static var description = IntentDescription(
        "Display your most recent dog walk entry, and choose to delete it or open it in the app to make changes."
    )

    @MainActor
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity?> & ProvidesDialog & ShowsSnippetIntent {
        let walkEntity = try await DataModelHelper.lastWalkOfToday()?.entity
        let dialog: IntentDialog = walkEntity == nil
            ? "No walk today yet!"
            : "Here is your latest walk. How did it go?"

        return .result(
            value: walkEntity,
            dialog: dialog,
            snippetIntent: LatestWalkSnippetIntent()
        )
    }
}

// SnippetIntent: iOS 26.0
/// Renders the latest walk. `perform()` only reads: the system re-runs it
/// after every button tap (rate, delete) to redraw the card in place.
struct LatestWalkSnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource = "Latest Walk Snippet"
    static let isDiscoverable = false

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let walkEntity = try await DataModelHelper.lastWalkOfToday()?.entity
        return .result(view: ManageLastWalkEntrySnippetView(walkEntity: walkEntity))
    }
}
