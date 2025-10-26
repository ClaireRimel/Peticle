//
//  DataModel+Exensions.swift
//  Peticle
//
//  Created by Claire on 25/10/2025.
//

import Foundation
import SwiftData

extension DataModelHelper {
    static func addDog(name: String, imageData: Data? = nil, age: Int) throws -> Dog {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dog = Dog(name: name, imageData: imageData, age: age)
        modelContext.insert(dog)
        try modelContext.save()

        DogWalkShortcutsProvider.updateAppShortcutParameters()

        return dog
    }

    @MainActor
    static func deleteDog(for identifier: UUID) async throws {
        let modelContext = ModelContext(DataModel.shared.modelContainer)

        var fetchDescriptor = FetchDescriptor<Dog>(
            predicate: #Predicate { $0.dogID == identifier }
        )
        fetchDescriptor.fetchLimit = 1

        if let dog = try modelContext.fetch(fetchDescriptor).first {
            modelContext.delete(dog)
            try modelContext.save()
            DogWalkShortcutsProvider.updateAppShortcutParameters()
        } else {
            throw DataModelHelperError.NoEntryFound(identifier)
        }
    }

    @MainActor
    static func dog(for identifier: UUID) async throws -> Dog? {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dog = try modelContext.fetch(FetchDescriptor<Dog>(predicate: #Predicate { identifier == $0.dogID })).first

        return dog
    }

    @MainActor
    static func dogs(for identifiers: [UUID]) async throws -> [Dog] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let allDogs = try modelContext.fetch(FetchDescriptor<Dog>())

        return allDogs.filter { identifiers.contains($0.dogID) }
    }

    @MainActor
    static func allDogs() async throws -> [Dog] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<Dog>(predicate: #Predicate { _ in true})
        let dogs = try modelContext.fetch(descriptor)

        return dogs
    }

    static func dogEntries(limit: Int) async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<DogWalkEntry>(predicate: #Predicate { _ in true})
        descriptor.fetchLimit = limit
        descriptor.sortBy = [SortDescriptor(\.entryDate, order: .reverse)]

        let entries = try modelContext.fetch(descriptor)

        return entries
    }

    @MainActor
    // Set to MainActor, because it is used with OpenIntent
    static func lastDogEntry() async throws -> DogWalkEntry? {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<DogWalkEntry>(sortBy: [SortDescriptor(\.entryDate, order: .reverse)])
        descriptor.fetchLimit = 1
        let entries = try modelContext.fetch(descriptor).first

        return entries
    }

    @MainActor
    static func allDogEntries() async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<DogWalkEntry>(predicate: #Predicate { _ in true})
        let entries = try modelContext.fetch(descriptor)

        return entries
    }
}
