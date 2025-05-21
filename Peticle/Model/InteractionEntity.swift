//
//  InteractionEntity.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import SwiftData

@Model
final class InteractionEntity {
    var interactionCount: Int
    var interactionRating: InteractionRating
    
    init(interactionCount: Int, interactionRating: InteractionRating) {
        self.interactionCount = interactionCount
        self.interactionRating = interactionRating
    }
}
