//
//  DogWalkEntry.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import SwiftData

@Model
final class DogWalkEntry: Identifiable {
    @Attribute(.unique) var dogWalkID: UUID
    var entryDate: Date
    var durationInMinutes: Int
    var walkQuality: WalkQuality
    
    init(
        dogWalkID: UUID = UUID(),
        entryDate: Date = .now,
        durationInMinutes: Int,
        walkQuality: WalkQuality = .ok
    ) {
        self.dogWalkID = dogWalkID
        self.entryDate = entryDate
        self.durationInMinutes = max(0, min(durationInMinutes, 1440))  // Max 24 hours
        self.walkQuality = walkQuality
    }
}

extension DogWalkEntry {
    var entity: DogWalkEntryEntity {
        DogWalkEntryEntity(self)
    }
}
