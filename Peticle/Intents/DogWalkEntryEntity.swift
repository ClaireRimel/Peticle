//
//  DogWalkEntryEntity.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import AppIntents
import CoreSpotlight

@AssistantEntity(schema: .journal.entry)
/// A SwiftData entity representing a logged dog walk, used in Journal integration and App Intents
struct DogWalkEntryEntity: IndexedEntity, Identifiable {
    
    /// The default query used to fetch dog walk entries, for use with App Intents
    static let defaultQuery = DogWalkQuery()
    
    /// Provides a display name for this entry, shown in Shortcuts or Siri
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: title ?? "No Title")
    }
    
    let id: UUID
    var title: String?
    var entryDate: Date?
    var humainInteraction: InteractionEntity?
    var dogInteraction: InteractionEntity?
    
    init(_ entry: DogWalkEntry) {
        id = entry.dogWalkID
        title = entry.entryDate.formatted(date: .abbreviated, time: .shortened)
        entryDate = entry.entryDate
        humainInteraction = entry.humainInteraction
        dogInteraction = entry.dogInteraction
    }
}

extension DogWalkEntryEntity {
    /// A Spotlight compatible attribute set used for indexing this entry
    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = defaultAttributeSet
        attributeSet.title = title
    
        return attributeSet
    }
}

/// A query that supports App Intents like Siri and Shortcuts, used to fetch or suggest dog walk entries
struct DogWalkQuery: EntityQuery {
    @MainActor
    /// Returns the list of dog walk entries matching the given identifiers
    func entities(for identifiers: [DogWalkEntryEntity.ID]) async throws -> [DogWalkEntryEntity] {
        let entries = try await DataModelHelper.dogWalkEntries(for: identifiers)
        return entries.map(\.entity)
    }
    
    /// Returns a list of suggested dog walk entries, limited to recent items
    func suggestedEntities() async throws -> [DogWalkEntryEntity] {
        let entries = try await DataModelHelper.dogEntries(limit: 5)
        return entries.map(\.entity)
    }
}
