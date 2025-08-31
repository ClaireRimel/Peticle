//
//  NavigationManager.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import SwiftUI
import SwiftData

@MainActor @Observable
final class NavigationManager {
    var searchText = ""
    var dogWalkNavigationPath = NavigationPath()
    var dogWalkEntry: DogWalkEntry?
    var modifyEntry: DogWalkEntry?

    // MARK: Methods
    @MainActor
    func openSearch(with criteria: String) {
        searchText = criteria
    }
    
    func composeNewDogWalkEntry() {
        dogWalkEntry = DogWalkEntry(durationInMinutes: 0)
    }
    
    func clearDogWalkEntry() {
        dogWalkEntry = nil
        modifyEntry = nil
    }
    
    func openLastDogWalkEntry() async throws {
        guard let latestEntry = try await DataModelHelper.lastDogEntry() else {
            return
        }
        modifyEntry = latestEntry
    }

    func navigateToRoot() {
        dogWalkNavigationPath.removeLast(dogWalkNavigationPath.count)
    }
}
