//
//  UpdateAppIntent.swift
//  Peticle
//
//  Created by Claire on 20/10/2025.
//

import AppIntents

struct UpdateAppShortcutsIntent: AppIntent {
    static var title: LocalizedStringResource = "Update catalog"
    static var description = IntentDescription("Use to update the app shorcuts catalog")

    func perform() async throws -> some IntentResult {
        DogWalkShortcutsProvider.updateAppShortcutParameters()

        return .result()
    }
}
