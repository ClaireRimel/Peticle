//
//  CreateFullNewEntryIntent.swift
//  Peticle
//
//  Created by Claire on 22/05/2025.
//

import AppIntents
import CoreLocation
import CoreSpotlight

struct CreateFullNewEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Create New Entry with details"
    
    @Parameter(title: "Duration In Minutes")
    var duration: Int?
    
    @Parameter(title: "Human Interaction Rating")
    var humanInteractionRating: InteractionRating?
    
    @Parameter(title: "Dog Interaction Rating")
    var dogInteractionRating: InteractionRating?
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity> {
        do {
            let entry = try DataModelHelper.newEntry(durationInMinutes: duration ?? 0,
                                                     humanInteraction: humanInteractionRating ?? .none,
                                                     dogInteraction:  dogInteractionRating ?? .none)
            
            try? await CSSearchableIndex.default().indexAppEntities([entry.entity])
            
            return .result(value: entry.entity)
            
        } catch {
            throw IntentError.noEntity
        }
    }
}
