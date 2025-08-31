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
    var humainInteraction: InteractionEntity
    var dogInteraction: InteractionEntity
    
    init(entryDate: Date = .now,
         durationInMinutes: Int,
         humainInteraction: InteractionEntity = InteractionEntity(interactionRating: .none),
         dogInteraction: InteractionEntity = InteractionEntity(interactionRating: .none)
    ) {
        // Validate and sanitize inputs
        let safeDuration = max(0, min(durationInMinutes, 1440)) // Max 24 hours
        let safeDate = entryDate
        
        dogWalkID = UUID()
        self.entryDate = safeDate
        self.durationInMinutes = safeDuration
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

