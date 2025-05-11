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
    var timestamp: Date
    var durationInMinutes: Int
    var humanInteractionCount: Int
    var humanInteractionRating: InteractionRating
    var dogInteractionCount: Int
    var dogInteractionRating: InteractionRating
    
    init(timestamp: Date = .now,
         durationInMinutes: Int,
         humanInteractionCount: Int = 0,
         humanInteractionRating: InteractionRating = .none,
         dogInteractionCount: Int = 0,
         dogInteractionRating: InteractionRating = .none
    ) {
        dogWalkID = UUID()
        self.timestamp = timestamp
        self.durationInMinutes = durationInMinutes
        self.humanInteractionCount = humanInteractionCount
        self.humanInteractionRating = humanInteractionRating
        self.dogInteractionCount = dogInteractionCount
        self.dogInteractionRating = dogInteractionRating
    }
}
