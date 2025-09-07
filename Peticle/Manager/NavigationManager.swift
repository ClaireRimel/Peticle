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

    var shouldShowSecretView: Bool = false

    // MARK: Methods
    func openSearch(with criteria: String) {
        searchText = criteria
    }
    
    func composeNewDogWalkEntry() {
        dogWalkEntry = DogWalkEntry(durationInMinutes: 0)
    }
    
    func clearDogWalkEntry() {
        dogWalkEntry = nil
        modifyEntry = nil
        shouldShowSecretView = false
    }
    
    func openEditDogWalk(for id: UUID) async throws {
        modifyEntry = try await DataModelHelper.dogWalkEntry(for: id)
    }
    
    func openLastDogWalk() async throws {
        guard let latestEntry = try await DataModelHelper.lastDogEntry() else {
            return
        }
        modifyEntry = latestEntry
    }
    
    func showSecretView() {
        shouldShowSecretView = true
    }
    
    func navigateToRoot() {
        dogWalkNavigationPath.removeLast(dogWalkNavigationPath.count)
    }
}
