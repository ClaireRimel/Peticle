//
//  SpeciesEntity.swift
//  Peticle
//
//  Species are created by the user, so they're an AppEntity (dynamic data
//  found by a query), not an AppEnum (a set fixed at compile time).
//  Shared with the widget extension.
//

import AppIntents
import CoreSpotlight
import SwiftData

struct SpeciesEntity: IndexedEntity, Identifiable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Species")

    static let defaultQuery = SpeciesQuery()

    let id: UUID

    @Property(title: "Name")
    var name: String

    var symbolName: String

    /// The user's symbol shows in Shortcuts pickers, Siri's "which one?"
    /// list and Spotlight. The plural synonym lets "Show my cats" match "Cat".
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            image: .init(systemName: symbolName),
            synonyms: ["\(name)s"]
        )
    }

    init(_ species: Species) {
        id = species.speciesID
        symbolName = species.symbolName
        name = species.name
    }
}

// MARK: - Query

struct SpeciesQuery: EntityStringQuery, EnumerableEntityQuery {
    @MainActor
    func entities(for identifiers: [SpeciesEntity.ID]) async throws -> [SpeciesEntity] {
        try DataModelHelper.allSpecies().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [SpeciesEntity] {
        try DataModelHelper.allSpecies()
    }

    @MainActor
    func allEntities() async throws -> [SpeciesEntity] {
        try DataModelHelper.allSpecies()
    }

    @MainActor
    func entities(matching string: String) async throws -> [SpeciesEntity] {
        try DataModelHelper.allSpecies().filter {
            string.localizedStandardContains($0.name) || $0.name.localizedStandardContains(string)
        }
    }
}

// MARK: - Symbols

/// The symbols offered when creating a species. A fixed list, so an
/// AppEnum: Shortcuts shows each choice with its icon.
enum SpeciesSymbol: String, AppEnum {
    case dog = "dog.fill"
    case cat = "cat.fill"
    case bird = "bird.fill"
    case fish = "fish.fill"
    case rabbit = "hare.fill"
    case turtle = "tortoise.fill"
    case lizard = "lizard.fill"
    case other = "pawprint.fill"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Symbol"

    static let caseDisplayRepresentations: [SpeciesSymbol: DisplayRepresentation] = [
        .dog: DisplayRepresentation(title: "Dog", image: .init(systemName: "dog.fill")),
        .cat: DisplayRepresentation(title: "Cat", image: .init(systemName: "cat.fill")),
        .bird: DisplayRepresentation(title: "Bird", image: .init(systemName: "bird.fill")),
        .fish: DisplayRepresentation(title: "Fish", image: .init(systemName: "fish.fill")),
        .rabbit: DisplayRepresentation(title: "Rabbit", image: .init(systemName: "hare.fill")),
        .turtle: DisplayRepresentation(title: "Turtle", image: .init(systemName: "tortoise.fill")),
        .lizard: DisplayRepresentation(title: "Lizard", image: .init(systemName: "lizard.fill")),
        .other: DisplayRepresentation(title: "Other", image: .init(systemName: "pawprint.fill")),
    ]
}

// MARK: - Data helpers

extension DataModelHelper {
    static func allSpecies() throws -> [SpeciesEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        return try modelContext.fetch(FetchDescriptor<Species>(sortBy: [SortDescriptor(\.name)])).map(SpeciesEntity.init)
    }

    /// Reuses a species with the same name ("cat" = "Cat") instead of
    /// creating a duplicate.
    static func createSpecies(name: String, symbol: SpeciesSymbol) throws -> SpeciesEntity {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let existing = try modelContext.fetch(FetchDescriptor<Species>())
        if let match = existing.first(where: { $0.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }) {
            return match.entity
        }

        let species = Species(name: trimmed, symbolName: symbol.rawValue)
        modelContext.insert(species)
        try modelContext.save()
        let entity = species.entity
        // Species can be said in phrases ("Add a cat"): tell the system.
        DogWalkShortcutsProvider.updateAppShortcutParameters()
        Task { try? await CSSearchableIndex.default().indexAppEntities([entity]) }
        return entity
    }

    /// One-time setup: existing animals were all dogs, so they get a "Dog"
    /// species when none exists yet.
    static func seedDefaultSpeciesIfNeeded() throws {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        guard try modelContext.fetchCount(FetchDescriptor<Species>()) == 0 else { return }

        let dog = Species(name: "Dog", symbolName: SpeciesSymbol.dog.rawValue)
        modelContext.insert(dog)
        for animal in try modelContext.fetch(FetchDescriptor<Dog>()) where animal.species == nil {
            animal.species = dog
        }
        try modelContext.save()
        DogWalkShortcutsProvider.updateAppShortcutParameters()
    }
}
