//
//  DogEntity.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import CoreSpotlight
import WidgetKit
import SwiftUI

/// A SwiftData entity representing a dog, used in app integration and App Intents
struct DogEntity: IndexedEntity, Identifiable {
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Dog")
    
    /// The default query used to fetch dogs, for use with App Intents
    static let defaultQuery = DogQuery()
    
    /// Provides a display name for this dog, shown in Shortcuts or Siri
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            image: .init(data: imageData ?? Data())
        )
    }

    
    let id: UUID
    
    @Property(indexingKey: \.addedDate)
    var addedDate: Date
    
    @Property var name: String
    @Property var age: Int
    var imageData: Data?

    init(_ dog: Dog) {
        id = dog.dogID
        addedDate = dog.addedDate
        imageData = dog.imageData
        name = dog.name
        age = dog.age
    }
}

extension DogEntity {
    /// A Spotlight compatible attribute set used for indexing this dog
    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = defaultAttributeSet
        attributeSet.title = name
        attributeSet.contentDescription = "\(age) years old"
        attributeSet.keywords = [name, "dog", "pet", "\(age) years old"]
        
        return attributeSet
    }
}

/// A query that supports App Intents like Siri and Shortcuts, used to fetch or suggest dogs
struct DogQuery: EntityQuery {
    @MainActor
    /// Returns the list of dogs matching the given identifiers
    func entities(for identifiers: [DogEntity.ID]) async throws -> [DogEntity] {
        let dogs = try await DataModelHelper.dogs(for: identifiers)
        return dogs.map(\.entity)
    }
    
    @MainActor
    /// Returns a list of suggested dogs, limited to recent items
    func suggestedEntities() async throws -> [DogEntity] {
        let dogs = try await DataModelHelper.allDogs()
        return dogs.map(\.entity)
    }
}

/// EnumerableEntityQuery: A specialization that lets the system enumerate all dogs
extension DogQuery: EnumerableEntityQuery {
    func allEntities() async throws -> [DogEntity] {
        let dogs = try await DataModelHelper.allDogs()
        return dogs.map(\.entity)
    }
}

/// EntityStringQuery: Enables natural language search for dogs by name from Siri and Shortcuts
extension DogQuery: EntityStringQuery {
    @MainActor
    func entities(matching string: String) async throws -> [DogEntity] {
        let allDogs = try await DataModelHelper.allDogs()
        return allDogs
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map(\.entity)
    }
}
