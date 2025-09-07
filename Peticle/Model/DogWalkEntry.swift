//
//  DogWalkEntry.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import SwiftData

@Model
final class DogWalkEntry: Identifiable, Sendable {
    @Attribute(.unique) var dogWalkID: UUID
    var entryDate: Date
    var durationInMinutes: Int
    var humainInteraction: InteractionRating
    var dogInteraction: InteractionRating
    
    init(
        dogWalkID: UUID = UUID(),
        entryDate: Date = .now,
        durationInMinutes: Int,
        humainInteraction: InteractionRating = .none,
        dogInteraction: InteractionRating = .none
    ) {
        self.dogWalkID = dogWalkID
        self.entryDate = entryDate
        self.durationInMinutes = max(0, min(durationInMinutes, 1440))  // Max 24 hours
        self.humainInteraction = humainInteraction
        self.dogInteraction = dogInteraction
    }
}

extension DogWalkEntry {
    var entity: DogWalkEntryEntity {
        let entity = DogWalkEntryEntity(self)
        return entity
    }
}

