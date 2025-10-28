//
//  OpenSecretViewWalkIntent.swift
//  Peticle
//
//  Created by Claire on 22/05/2025.
//

import AppIntents

struct OpenSecretViewWalkIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Secret View"
    static var description = IntentDescription("Open the app and find a hidden feature")

    static var isDiscoverable = false
    
    /// Wakes up the app and brings it to foreground (for iOS 16-18)
    static let openAppWhenRun = true

    /// Wakes up and foregrounds app (ios 26)
    static let supportedModes: IntentModes = [.foreground(.immediate)]

    init() {}
    
    @MainActor
    func perform() throws -> some IntentResult {
        guard let navigationManager: NavigationManager =
                AppDependencyManager.shared.get() else {
            throw IntentError.message("⚠️ Could not resolve NavigationManager. Make sure it's registered in AppDependencyManager.")
        }

        navigationManager.shouldShowSecretFeature = true
        return .result()
    }
}
