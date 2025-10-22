//
//  OpenEditEntryIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

struct OpenEditEntryIntent: OpenIntent {
    // Required for OpenIntent
       typealias Value = DogWalkEntryEntity

    static var title: LocalizedStringResource = "Edit a Dog Walk Entry"
    static var description = IntentDescription("Open the app to edit the selected dog walk entry.")
    
    
    @Parameter(title: "Walk Entry", description: "The dog walk entry to edit")
    var target: DogWalkEntryEntity
//    
//    // Wakes up the app and brings it to foreground (iOS 16–18)
//    static let openAppWhenRun = true
//    
//    // Wakes up and foregrounds app  (iOS 26)
//    static let supportedModes: IntentModes = [.foreground(.immediate)]
    
    init() {}

    init(target: DogWalkEntryEntity) {
        self.target = target
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Get NavigationManager from AppDependencyManager
        guard let navigationManager: NavigationManager =
                AppDependencyManager.shared.get() else {
            throw IntentError.message("⚠️ Could not resolve NavigationManager. Make sure it's registered in AppDependencyManager.")
        }
        
        try await navigationManager.openEditDogWalk(for: target.id)
        return .result()
    }
}

