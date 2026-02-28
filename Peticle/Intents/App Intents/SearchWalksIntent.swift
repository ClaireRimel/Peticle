//
//  SearchWalksIntent.swift
//  Peticle
//
//  Created by Claire on 28/02/2026.
//

import AppIntents

/// ShowInAppSearchResultsIntent: Opens the app and navigates to search results for dog walks.
/// The system understands this is a search action and can route search queries to this intent.
@AppIntent(schema: .system.search)
struct SearchWalksIntent: ShowInAppSearchResultsIntent {
    static var title: LocalizedStringResource = "Search Dog Walks"
    static var description = IntentDescription(
        "Search your dog walk history and show matching results in the app."
    )

    static var searchScopes: [StringSearchScope] = [.general]

    @Parameter(title: "Search term")
    var criteria: StringSearchCriteria

    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let navigationManager: NavigationManager = AppDependencyManager.shared.get() else {
            throw IntentError.message("Unable to open search. Please try again.")
        }

        navigationManager.navigateToRoot()
        navigationManager.openSearch(with: criteria.term)

        return .result()
    }
}
