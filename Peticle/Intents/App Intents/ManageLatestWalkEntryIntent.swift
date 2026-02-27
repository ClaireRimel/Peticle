//
//  ManageLastWalkEntryIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

// SnippetIntent: iOS 26.0
struct ManageLatestWalkEntryIntent: SnippetIntent {
    static var title: LocalizedStringResource = "Last Walk Entry"
    static var description = IntentDescription(
        "Display your most recent dog walk entry, and choose to delete it or open it in the app to make changes."
    )

    
    @MainActor
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity?> & ShowsSnippetView {
        let walkEntity = try await DataModelHelper.walksOfToday().compactMap { entry in
            DogWalkEntryEntity(entry)
        }.last
                
        return .result(
            value: walkEntity,
            view: ManageLastWalkEntrySnippetView(walkEntity: walkEntity)
        )
    }
}
