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

    var shouldShowSecretFeature: Bool = false

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
        shouldShowSecretFeature = false
    }

    func navigateToRoot() {
        dogWalkNavigationPath.removeLast(dogWalkNavigationPath.count)
    }
}
