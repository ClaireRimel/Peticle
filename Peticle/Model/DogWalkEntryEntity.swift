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
        title: LocalizedStringResource("Duration in Minutes")
    )
    var durationInMinutes: Int

    @Property(title: "Walk Quality")
    var walkQuality: WalkQuality?

    // MARK: - Computed Properties for Spotlight

    @ComputedProperty(title: "Time Ago")
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: .now)
    }

    init(_ entry: DogWalkEntry) {
        id = entry.dogWalkID
        date = entry.entryDate
        durationInMinutes = entry.durationInMinutes
        walkQuality = entry.walkQuality
    }
}

// MARK: - Spotlight Indexing

extension DogWalkEntryEntity {
    /// A Spotlight compatible attribute set used for indexing this entry
    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = defaultAttributeSet
        attributeSet.title = String(describing: durationInMinutes)
        attributeSet.contentDescription = timeAgo
        return attributeSet
    }
}

// MARK: - URLRepresentableEntity

extension DogWalkEntryEntity: URLRepresentableEntity {
    static var urlRepresentation: URLRepresentation {
        "https://peticle.example.com/walk/\(.id)"
    }
}

// MARK: - Comparator Mapping for EntityPropertyQuery

/// Custom comparator type used by EntityPropertyQuery to filter dog walk entries.
/// Each comparator captures a closure that tests whether an entity matches the filter criteria.
struct DogWalkComparator {
    let matches: (DogWalkEntryEntity) -> Bool
}

// MARK: - Entity Query

/// A query that supports App Intents like Siri and Shortcuts, used to fetch or suggest dog walk entries
/// EntityPropertyQuery: Advanced query with filterable properties and sorting — auto-generates "Find Dog Walks" in Shortcuts
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

// MARK: - EntityPropertyQuery — "Find Dog Walks" in Shortcuts

extension DogWalkQuery: EntityPropertyQuery {
    typealias ComparatorMappingType = DogWalkComparator

    static var findIntentDescription: IntentDescription? {
        IntentDescription("Search for dog walks matching specific criteria.",
                          categoryName: "Walks",
                          searchKeywords: ["walk", "dog", "duration", "quality"],
                          resultValueName: "Dog Walks")
    }

    static var properties = QueryProperties {
        Property(\DogWalkEntryEntity.$date) {
            EqualToComparator { date in
                DogWalkComparator { $0.date == date }
            }
            GreaterThanComparator { date in
                DogWalkComparator { $0.date > date }
            }
            LessThanComparator { date in
                DogWalkComparator { $0.date < date }
            }
        }
        Property(\DogWalkEntryEntity.$durationInMinutes) {
            EqualToComparator { duration in
                DogWalkComparator { $0.durationInMinutes == duration }
            }
            GreaterThanComparator { duration in
                DogWalkComparator { $0.durationInMinutes > duration }
            }
            LessThanComparator { duration in
                DogWalkComparator { $0.durationInMinutes < duration }
            }
        }
        Property(\DogWalkEntryEntity.$walkQuality) {
            EqualToComparator { quality in
                DogWalkComparator { $0.walkQuality == quality }
            }
        }
    }

    static var sortingOptions = SortingOptions {
        SortableBy(\DogWalkEntryEntity.$date)
        SortableBy(\DogWalkEntryEntity.$durationInMinutes)
    }

    @MainActor
    func entities(
        matching comparators: [DogWalkComparator],
        mode: ComparatorMode,
        sortedBy: [EntityQuerySort<DogWalkEntryEntity>],
        limit: Int?
    ) async throws -> [DogWalkEntryEntity] {
        // Fetch all entries and filter in memory
        let allEntries = try await DataModelHelper.allDogWalkEntries()
        var results = allEntries.map(\.entity)

        // Apply comparators
        results = results.filter { entity in
            if mode == .and {
                return comparators.allSatisfy { $0.matches(entity) }
            } else {
                return comparators.isEmpty || comparators.contains { $0.matches(entity) }
            }
        }

        // Apply sorting
        for sortOption in sortedBy.reversed() {
            switch sortOption.by {
            case \.$date:
                results.sort {
                    sortOption.order == .ascending ? $0.date < $1.date : $0.date > $1.date
                }
            case \.$durationInMinutes:
                results.sort {
                    sortOption.order == .ascending
                        ? $0.durationInMinutes < $1.durationInMinutes
                        : $0.durationInMinutes > $1.durationInMinutes
                }
            default:
                break
            }
        }

        // Apply limit
        if let limit {
            results = Array(results.prefix(limit))
        }

        return results
    }
}
