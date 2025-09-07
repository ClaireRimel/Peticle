//
//  DogWalkIntents.swift
//  Peticle
//
//  Created by Claire on 21/05/2025.
//

import AppIntents
import CoreSpotlight

struct OpenNewDogWalkIIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a New Dog Walk"
    static var description = IntentDescription("Opens the app and starts registering a new dog walk")

    @Dependency
    private var navigationManager: NavigationManager
    
    // Use to wake up the app
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        navigationManager.composeNewDogWalkEntry()
        return .result()
    }
}

struct OpenLastEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Details to the Last Dog Walk Entry"
    static var description = IntentDescription("Opens the app and updates the last dog walk")

    @Dependency
    private var navigationManager: NavigationManager
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        try await navigationManager.openLastDogWalkEntry()
        return .result()
    }
}

struct WalksTodayCountIntent: AppIntent {
    static var title: LocalizedStringResource = "How many walks have you done today?"
    static var description = IntentDescription("Return the number of walks completed today")
    
    func perform() async throws -> some ReturnsValue<Int> {
        let walksTodayCount = try await DataModelHelper.walksTodayCount()
        
        return .result(value: walksTodayCount)
    }
}
