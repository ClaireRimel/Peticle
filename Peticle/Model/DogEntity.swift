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
import SwiftData

#if canImport(UIKit)
import UIKit
#endif

/// A SwiftData entity representing a dog, used in app integration and App Intents
struct DogEntity: IndexedEntity, Identifiable {

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Dog")

    /// The default query used to fetch dogs, for use with App Intents
    static let defaultQuery = DogQuery()

    /// Provides a display name for this dog, shown in Shortcuts or Siri
    var displayRepresentation: DisplayRepresentation {
        #if canImport(UIKit)
        if let imageData, !imageData.isEmpty,
           let image = UIImage(data: imageData),
           let thumbnail = image.preparingThumbnail(of: CGSize(width: 200, height: 200)),
           let normalizedData = thumbnail.jpegData(compressionQuality: 0.8) {
            return DisplayRepresentation(
                title: "\(name)",
                image: .init(data: normalizedData)
            )
        }
        #elseif canImport(AppKit)
        if let imageData, !imageData.isEmpty {
            return DisplayRepresentation(
                title: "\(name)",
                image: .init(data: imageData)
            )
        }
        #endif
        return DisplayRepresentation(title: "\(name)")
    }


    let id: UUID

    @Property(indexingKey: \.addedDate)
    var addedDate: Date

    @Property var name: String
    @Property var age: Int
    @Property(title: "Species") var species: SpeciesEntity?
    var imageData: Data?

    init(_ dog: Dog) {
        id = dog.dogID
        addedDate = dog.addedDate
        imageData = dog.imageData
        name = dog.name
        age = dog.age
        species = dog.species.map(SpeciesEntity.init)
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
/// IMPORTANT: DogEntity must be created in the same scope as the ModelContext
/// so that SwiftData binary data (imageData) is still accessible when copied.
struct DogQuery: EntityQuery {
    @MainActor
    /// Returns the list of dogs matching the given identifiers
    func entities(for identifiers: [DogEntity.ID]) async throws -> [DogEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let allDogs = try modelContext.fetch(FetchDescriptor<Dog>())
        return allDogs
            .filter { identifiers.contains($0.dogID) }
            .map { DogEntity($0) }
    }

    @MainActor
    /// Returns a list of suggested dogs, limited to recent items
    func suggestedEntities() async throws -> [DogEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dogs = try modelContext.fetch(FetchDescriptor<Dog>())
        return dogs.map { DogEntity($0) }
    }
}

/// EnumerableEntityQuery: A specialization that lets the system enumerate all dogs
extension DogQuery: EnumerableEntityQuery {
    func allEntities() async throws -> [DogEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dogs = try modelContext.fetch(FetchDescriptor<Dog>())
        return dogs.map { DogEntity($0) }
    }
}

/// EntityStringQuery: Enables natural language search for dogs by name from Siri and Shortcuts
extension DogQuery: EntityStringQuery {
    @MainActor
    func entities(matching string: String) async throws -> [DogEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let allDogs = try modelContext.fetch(FetchDescriptor<Dog>())
        return allDogs
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { DogEntity($0) }
    }
}
