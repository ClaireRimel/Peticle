//
//  DogWalkIntents.swift
//  Peticle
//
//  Created by Claire on 21/05/2025.
//

import AppIntents
import CoreSpotlight

struct CreateNewDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a New Dog Walk"
    static var description = IntentDescription("Register manually a new dog walk with interaction")
    
    @Parameter(title: "Dog Walk")
    var target: DogWalkEntryEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        _ = try DataModelHelper.newEntry(
            durationInMinutes: target.durationInMinutes,
            walkQuality: target.walkQuality ?? .ok
        )
        return .result()
    }
}

struct WalksTodayCountIntent: AppIntent {
    static var title: LocalizedStringResource = "How many walks have you done today?"
    static var description = IntentDescription("Return the number of walks completed today")
    
    @MainActor
    func perform() async throws -> some ReturnsValue<Int> {
        let walksTodayCount = try await DataModelHelper.walksTodayCount()
        
        return .result(value: walksTodayCount)
    }
}
