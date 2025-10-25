//
//  NavigationManager+Extension.swift
//  Peticle
//
//  Created by Claire on 25/10/2025.
//

import Foundation

extension NavigationManager {
    func openEditDogWalk(for id: UUID) async throws {
        modifyEntry = try await DataModelHelper.dogWalkEntry(for: id)
    }

    func openLastDogWalk() async throws {
        guard let latestEntry = try await DataModelHelper.lastDogEntry() else {
            return
        }
        modifyEntry = latestEntry
    }
}
