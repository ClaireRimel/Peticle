//
//  DeleteWalkIntent.swift
//  Peticle
//
//  Created by Claire on 06/09/2025.
//

import AppIntents
import Foundation
import CoreSpotlight

struct AddActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Activity Registration"
    static var description = IntentDescription("Add a New Dog Walk Entry with a Duration")
    
    @Parameter(title: "Duration", description: "The amount of minutes that you want to log")
    var duration: DurationPreset
        
    func perform() async throws -> some ProvidesDialog {
        let minutes = duration.minutes
        let newEntry = try DataModelHelper.newEntry(durationInMinutes: minutes,
                                         humainInteraction: .none,
                                         dogInteraction: .none)

        DogWalkShortcutsProvider.updateAppShortcutParameters()

        return .result(dialog: "The activity of \(minutes) minutes has been added successfully")
    }
}

struct DeleteWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete a Dog Walk Entry"
    static var description = IntentDescription("Remove a Dog Walk Entry")
    
    @Parameter(title: "Walk Entry", description: "Entity to delete")
    var walkEntity: DogWalkEntryEntity
    
    init() {}
    
    init(walkEntity: DogWalkEntryEntity) {
        self.walkEntity = walkEntity
    }
    
    // ShowsSnippetIntent: iOS 26.0
    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        try await DataModelHelper.deleteWalk(for: walkEntity.id)
     
        // SnippetIntent: iOS 26.0
        CheckEntryOfTheDay.reload()
        DogWalkShortcutsProvider.updateAppShortcutParameters()
        
        return .result(snippetIntent: CheckEntryOfTheDay())
    }
}

// SnippetIntent: iOS 26.0
struct CheckEntryOfTheDay: SnippetIntent {
    static var title: LocalizedStringResource = "Check Entry Of The Day"
    static var description = IntentDescription("Use to delete entry if needed")
    
    func perform() async throws -> some ReturnsValue<[DogWalkEntryEntity]> & ShowsSnippetView {
        let walkEntities = try await DataModelHelper.walksOfToday().compactMap { entry in
            DogWalkEntryEntity(entry)
        }
        
        return .result(
            value: walkEntities,
            view: ListWalksOfTheDaySnippetView(walkEntities: walkEntities)
        )
    }
}
