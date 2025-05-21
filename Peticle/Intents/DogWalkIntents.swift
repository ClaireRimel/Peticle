//
//  DogWalkIntents.swift
//  Peticle
//
//  Created by Claire on 21/05/2025.
//

import AppIntents

struct NewDogWalkIntent: AppIntent {
    static let title: LocalizedStringResource = "Add New Dog Walk Entry"
    
    static var isDiscoverable = false
    
    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: OpenNewDogWalkIIntent())
    }
}

struct AddDetailDogWalkIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Add Details to the Last Dog Walk Entry"
    
    static var isDiscoverable = false
    
    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: OpenLastEntryIIntent())
    }
}

struct AddActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Activity Registration"
    static var description = IntentDescription("Add a New Dog Walk Entry with a Duration")
    
    @Parameter(title: "Duration", description: "The amount of minutes that you want to log")
    var duration: DurationPreset
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let minutes = duration.minutes
        _ = try DataModelHelper.newEntry(durationInMinutes: minutes,
                                         humainInteraction: InteractionEntity(interactionCount: 0,
                                                                              interactionRating: .none),
                                         dogInteraction: InteractionEntity(interactionCount: 0,
                                                                           interactionRating: .none))
        return .result(dialog: "The activity of \(minutes) minutes has been added successfully")
    }
}

struct WalksTodayCountIntent: AppIntent {
    static var title: LocalizedStringResource = "How many walks have you done today?"
    static var description = IntentDescription("Return the number of walks completed today")
    
    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        let walksTodayCount = try await DataModelHelper.walksTodayCount()
        
        return .result(value: walksTodayCount)
    }
}
