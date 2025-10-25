//
//  DataModel+Exensions.swift
//  Peticle
//
//  Created by Claire on 25/10/2025.
//

import Foundation
import SwiftData

extension DataModelHelper {
    static func newEntry(durationInMinutes: Int, walkQuality: WalkQuality) throws -> DogWalkEntry {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let entry = DogWalkEntry(durationInMinutes: durationInMinutes,
                                     walkQuality: walkQuality)
        modelContext.insert(entry)
        try modelContext.save()

        DogWalkShortcutsProvider.updateAppShortcutParameters()
        return entry
    }

    @MainActor
    static func modify(entryWalk: DogWalkEntry) async throws -> DogWalkEntry? {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dogWalkID = entryWalk.dogWalkID

        var descriptor = FetchDescriptor<DogWalkEntry>(
            predicate: #Predicate { $0.dogWalkID == dogWalkID }
        )
        descriptor.fetchLimit = 1

        guard let entry = try modelContext.fetch(descriptor).first else {
            print("❌ No matching entry found for ID \(entryWalk.dogWalkID)")
            return nil
        }

        entry.walkQuality = entryWalk.walkQuality
        entry.durationInMinutes = entryWalk.durationInMinutes

        try modelContext.save()

        DogWalkShortcutsProvider.updateAppShortcutParameters()

        return entry
    }

    static func addDog(name: String, imageData: Data? = nil, age: Int) throws -> Dog {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dog = Dog(name: name, imageData: imageData, age: age)
        modelContext.insert(dog)
        try modelContext.save()

        DogWalkShortcutsProvider.updateAppShortcutParameters()

        return dog
    }
    
    @MainActor
    static func deleteWalk(for identifier: UUID) async throws {
        let modelContext = ModelContext(DataModel.shared.modelContainer)

        var fetchDescriptor = FetchDescriptor<DogWalkEntry>(
            predicate: #Predicate { $0.dogWalkID == identifier }
        )
        fetchDescriptor.fetchLimit = 1

        if let entry = try modelContext.fetch(fetchDescriptor).first {
            modelContext.delete(entry)
            try modelContext.save()
            DogWalkShortcutsProvider.updateAppShortcutParameters()

        } else {
            throw DataModelHelperError.NoEntryFound(identifier)
        }
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
}
