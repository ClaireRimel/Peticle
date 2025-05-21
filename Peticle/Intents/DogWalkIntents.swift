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

    static let title: LocalizedStringResource = "Add Detail Last Dog Walk Entry"

    static var isDiscoverable = false

    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: OpenLastEntryIIntent())
    }
}

struct AddActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Activity registation"

    static var description = IntentDescription("Add New Dog Walk Entry with a duration")
    
    @Parameter(title: "Duration", description: "The amount of minuts tha you want log")
    var duration: DurationPreset

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let minutes = duration.minutes
        _ = try DataModelHelper.newEntry(durationInMinutes: minutes,
                                         humainInteraction: InteractionEntity(interactionCount: 0,
                                                                              interactionRating: .none),
                                         dogInteraction: InteractionEntity(interactionCount: 0,
                                                                           interactionRating: .none))
        return .result(dialog: "The activity of \(minutes) minutes was added successfully.")
    }
}

enum DurationPreset: String, AppEnum {
    case thirty = "30"
    case forty = "40"
    case fifty = "50"
    case sixty = "60"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Durée")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .thirty: "30 minutes",
        .forty: "40 minutes",
        .fifty: "50 minutes",
        .sixty: "1 hour"
    ]

    var minutes: Int {
        Int(rawValue) ?? 0
    }
}

struct IsLastWalkWasTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "How many walk have you done today?"
    
    static var description = IntentDescription("Return the number of walks done today")
    
    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        
        let walksTodayCount = try await DataModelHelper.walksTodayCount()
        
        return .result(value: walksTodayCount)
    }
}
