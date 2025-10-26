//
//  PeticleApp.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import SwiftUI
import AppIntents

@main
struct PeticleApp: App {
    let modelContainer = DataModel.shared.modelContainer
    let navigationManager: NavigationManager
    
    init() {
        let navigationManager = NavigationManager()
        /// Registration and initialization of an app intent's
        AppDependencyManager.shared.add(dependency: navigationManager)
        DogWalkShortcutsProvider.updateAppShortcutParameters()

        self.navigationManager = navigationManager
    }
    
    var body: some Scene {
        WindowGroup {
            DogWalkListView()
        }
        .modelContainer(modelContainer)
        .environment(navigationManager)
    }
}
