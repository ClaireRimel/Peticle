//
//  InteractionEntity.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import SwiftData

@Model
final class InteractionEntity: Sendable {
    var interactionRating: InteractionRating
    
    init(interactionRating: InteractionRating) {
        self.interactionRating = interactionRating
    }
}

extension InteractionEntity {
    // MARK: - Validation Methods
    var isValid: Bool {
        return true // No validation needed for rating only
    }
    
    var description: String {
        return interactionRating.localizedName()
    }
}
