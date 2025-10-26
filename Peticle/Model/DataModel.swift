//
//  DataModel.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import SwiftData

actor DataModel: Sendable {
    static let shared = DataModel()
    private init() {}
    
    nonisolated var modelContainer: ModelContainer {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: DogWalkEntry.self, Dog.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        
        return modelContainer
    }
}

class DataModelHelper {
    @MainActor
    // Set to MainActor, because it is used with OpenIntent
    static func dogWalkEntries(for identifiers: [UUID]) async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let allEntries = try modelContext.fetch(FetchDescriptor<DogWalkEntry>())

        return allEntries.filter { identifiers.contains($0.dogWalkID) }
    }

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

    static func dogWalkEntry(for identifier: UUID) async throws -> DogWalkEntry? {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let entry = try modelContext.fetch(FetchDescriptor<DogWalkEntry>(predicate: #Predicate { identifier == $0.dogWalkID })).first
        
        return entry
    }
    
    static func walksTodayCount() async throws -> Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicate = #Predicate<DogWalkEntry> {
            $0.entryDate >= startOfToday && $0.entryDate < startOfTomorrow
        }

        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<DogWalkEntry>(predicate: predicate)

        let entries = try modelContext.fetch(descriptor)
        return entries.count
    }
    
    static func walksOfToday() async throws -> [DogWalkEntry] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicate = #Predicate<DogWalkEntry> {
            $0.entryDate >= startOfToday && $0.entryDate < startOfTomorrow
        }

        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<DogWalkEntry>(predicate: predicate)

        let entries = try modelContext.fetch(descriptor)
        return entries
    }
    
    static func walksOfYesterday() async throws -> [DogWalkEntry] {
        let calendar = Calendar.current
        let startOfYesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: Date())!)
        let startOfToday = calendar.startOfDay(for: Date())

        let predicate = #Predicate<DogWalkEntry> {
            $0.entryDate >= startOfYesterday && $0.entryDate < startOfToday
        }

        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<DogWalkEntry>(predicate: predicate)

        let entries = try modelContext.fetch(descriptor)
        return entries
    }
    
    @MainActor
    static func lastWalkOfToday() async throws -> DogWalkEntry? {
        let walks = try await walksOfToday()
        return walks.sorted(by: { $0.entryDate > $1.entryDate }).first
    }
    
    @MainActor
    static func lastWalkOfYesterday() async throws -> DogWalkEntry? {
        let walks = try await walksOfYesterday()
        return walks.sorted(by: { $0.entryDate > $1.entryDate }).first
    }
    
    static func dogWalkEntries(limit: Int) async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<DogWalkEntry>(predicate: #Predicate { _ in true})
        descriptor.fetchLimit = limit
        let entries = try modelContext.fetch(descriptor)

        return entries
    }

    @MainActor
    static func allDogWalkEntries() async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<DogWalkEntry>(predicate: #Predicate { _ in true})
        let entries = try modelContext.fetch(descriptor)

        return entries
    }

}

// MARK: - Custom Errors
enum DataModelHelperError: LocalizedError, Error {
    case invalidDuration(Int)
    case NoEntryFound(_ identifier: UUID)

    var errorDescription: String? {
        switch self {
        case .invalidDuration(let duration):
            return "Invalid duration: \(duration) minutes. Duration must be between 0 and 1440 minutes."
        case .NoEntryFound(let identifier):
            return "No entry found for the given identifier:\(identifier)"
        }
    }
}
