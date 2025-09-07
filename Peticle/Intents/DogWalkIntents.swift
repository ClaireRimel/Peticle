//
//  DogWalkIntents.swift
//  Peticle
//
//  Created by Claire on 21/05/2025.
//

import AppIntents
import CoreSpotlight
import SwiftUI

struct CreateNewDogWalkIIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a New Dog Walk"
    static var description = IntentDescription("Register manually a new dog walk with interaction")
    
    @Parameter(title: "Dog Walk")
    var target: DogWalkEntryEntity

    @MainActor
    func perform() async throws -> some IntentResult {
       _ = try DataModelHelper.newEntry(durationInMinutes: target.durationInMinutes,
                                     humainInteraction: target.humainInteraction ?? .none,
                                     dogInteraction: target.dogInteraction ?? .none)
        return .result()
    }
}

struct OpenEntryIntent: OpenIntent {
    init() {}
    
    init(target: DogWalkEntryEntity) {
        self.target = target
    }
    
    typealias Value = DogWalkEntryEntity
    
    static var title: LocalizedStringResource = "Add Details to the Last Dog Walk Entry"
    static var description = IntentDescription("Opens the app and updates the last dog walk")
    
    @Parameter(title: "Dog Walk")
    var target: DogWalkEntryEntity
    
    // Wakes up the app and brings it to foreground (for iOS 17–25)
    static let openAppWhenRun = true
    
    // Wakes up and foregrounds app (for iOS 17–25)
    static let supportedModes: IntentModes = [.foreground(.immediate)]
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Get NavigationManager from AppDependencyManager
        guard let navigationManager: NavigationManager =
                AppDependencyManager.shared.get() else {
            throw IntentError.message("NavigationManager not available")
        }
        
        try await navigationManager.openEditDogWalk(for: target.id)
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
