//
//  OpenSecretViewWalkIntent.swift
//  Peticle
//
//  Created by Claire on 22/05/2025.
//

import AppIntents

struct OpenSecretViewWalkIntent: AppIntent {
    var value: Never?
    
    static let title: LocalizedStringResource = "Open Secret View With a secret photo of Alfie "
    
    static var isDiscoverable = false
    
    // Wakes up the app and brings it to foreground (for iOS 17-18)
    static let openAppWhenRun = true
    
    // Wakes up and foregrounds app (ios 26)
    static let supportedModes: IntentModes = [.foreground(.immediate)]

    func perform() async throws -> some IntentResult {
        guard let navigationManager: NavigationManager =
                AppDependencyManager.shared.get() else {
            throw IntentError.message("NavigationManager not available")
        }
        
        await navigationManager.showSecretView()
        return .result()
    }
}
