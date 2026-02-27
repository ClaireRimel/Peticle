//
//  DogWalkEntryEntity.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import AppIntents
import CoreSpotlight
import WidgetKit

/// A SwiftData entity representing a logged dog walk, used in app integration and App Intents
// IndexedEntity: iOS 18*
struct DogWalkEntryEntity: IndexedEntity, Identifiable, TimelineEntry {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Dog walk")

    /// The default query used to fetch dog walk entries, for use with App Intents
    static let defaultQuery = DogWalkQuery()
    
    /// Provides a display name for this entry, shown in Shortcuts or Siri
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: date.formatted(date: .abbreviated, time: .shortened))
    }
    
    let id: UUID
    
    @Property(
        title: LocalizedStringResource("Date of the walk"),
        indexingKey: \.addedDate
    )
    var date: Date

    @Property(
        identifier: "Duration",
        title: LocalizedStringResource(" Duration in Minute")
    )
    var durationInMinutes: Int

    var walkQuality: WalkQuality?
    
    init(_ entry: DogWalkEntry) {
        id = entry.dogWalkID
        date = entry.entryDate
        durationInMinutes = entry.durationInMinutes

        walkQuality = entry.walkQuality
    }
}

extension DogWalkEntryEntity {
    /// A Spotlight compatible attribute set used for indexing this entry
    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = defaultAttributeSet
        attributeSet.title = String(describing: durationInMinutes)
    
        return attributeSet
    }
}

/// A query that supports App Intents like Siri and Shortcuts, used to fetch or suggest dog walk entries
/// EntityQuery:  protocol for defining how to fetch entities, either by ID or suggestion.
struct DogWalkQuery: EntityQuery {
    @MainActor
    /// Returns the list of dog walk entries matching the given identifiers
    func entities(for identifiers: [DogWalkEntryEntity.ID]) async throws -> [DogWalkEntryEntity] {
        let entries = try await DataModelHelper.dogWalkEntries(for: identifiers)
        return entries.map(\.entity)
    }
    
    @MainActor
    /// Returns a list of suggested dog walk entries, limited to recent items
    func suggestedEntities() async throws -> [DogWalkEntryEntity] {
        let entries = try await DataModelHelper.dogWalkEntries(limit: 5)
        return entries.map(\.entity)
    }

    
}

/// EnumerableEntityQuery:  A specialization that lets the system enumerate all entities
/// useful when you want the full list (like showing all playlists, contacts, devices…).
extension DogWalkQuery: EnumerableEntityQuery {
    func allEntities() async throws -> [DogWalkEntryEntity] {
        let walks = try await DataModelHelper.allDogWalkEntries()
        return walks.map(\.entity)
    }
}
