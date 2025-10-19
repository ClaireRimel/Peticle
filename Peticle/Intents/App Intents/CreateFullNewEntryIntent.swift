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
    
    @Parameter(title: "Walk Quality Rating")
    var walkQualityRating: WalkQuality?
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity> {
        do {
            let entry = try DataModelHelper.newEntry(durationInMinutes: duration ?? 0,
                                                     walkQuality: walkQualityRating ?? .ok)
            
            try? await CSSearchableIndex.default().indexAppEntities([entry.entity])
            
            return .result(value: entry.entity)
            
        } catch {
            throw IntentError.noEntity
        }
    }
}
