//
//  PeticleApp.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import SwiftUI
import AppIntents
import SwiftData

@main
struct PeticleApp: App {
    let modelContainer = DataModel.shared.modelContainer
    let navigationManager: NavigationManager

    init() {
        let navigationManager = NavigationManager()
        /// Registration and initialization of an app intent's
        AppDependencyManager.shared.add(dependency: navigationManager)
        DogWalkShortcutsProvider.updateAppShortcutParameters()
        // Walks saved by Stop weren't indexed before: catch them up.
        Task {
            try? DataModelHelper.seedDefaultSpeciesIfNeeded()
            try? await DataModelHelper.reindexAllWalks()
            try? await DataModelHelper.reindexAllNotes()
            await Self.forgetMisleadingDonations()
        }

        self.navigationManager = navigationManager
    }

    /// One-time cleanup: every Stop used to donate AddWalkIntent, which
    /// steered Siri towards the wrong intent. (It also donated an
    /// EditWalkQualityIntent, since removed as a duplicate of
    /// UpdateWalkQualityIntent.)
    private static func forgetMisleadingDonations() async {
        let key = "didForgetStopDonations"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        let manager = IntentDonationManager.shared
        _ = try? await manager.deleteDonations(matching: .intentType(AddWalkIntent.self))
        UserDefaults.standard.set(true, forKey: key)
    }

    var body: some Scene {
        WindowGroup {
            DogWalkListView()
                .tint(.peticleBrand)
        }
        .modelContainer(modelContainer)
        .environment(navigationManager)
    }
}
