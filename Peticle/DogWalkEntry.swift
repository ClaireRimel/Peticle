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
    var timestamp: Date
    var durationInMinutes: Int
    var humanInteractionCount: Int
    var humanInteractionRating: Int
    var dogInteractionCount: Int
    var dogInteractionRating: Int
    
    init(timestamp: Date = Date(),
         durationInMinutes: Int,
         humanInteractionCount: Int,
         humanInteractionRating: Int,
         dogInteractionCount: Int,
         dogInteractionRating: Int
    ) {
        self.timestamp = timestamp
        self.durationInMinutes = durationInMinutes
        self.humanInteractionCount = humanInteractionCount
        self.humanInteractionRating = humanInteractionRating
        self.dogInteractionCount = dogInteractionCount
        self.dogInteractionRating = dogInteractionRating
    }
}
