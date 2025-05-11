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
    var humainInteraction: InteractionEntity?
    var dogInteraction: InteractionEntity?
    
    init(entryDate: Date = .now,
         durationInMinutes: Int,
         humainInteraction: InteractionEntity?,
         dogInteraction: InteractionEntity?
    ) {
        dogWalkID = UUID()
        self.entryDate = entryDate
        self.durationInMinutes = durationInMinutes
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

