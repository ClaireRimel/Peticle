//
//  DataModel.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import SwiftData

actor DataModel {
    static let shared = DataModel()
    private init() {}
    
    nonisolated var modelContainer: ModelContainer {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: DogWalkEntry.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        
        return modelContainer
    }
}

class DataModelHelper {
    static func newEntry(durationInMinutes: Int, humainInteraction: InteractionRating, dogInteraction: InteractionRating) throws -> DogWalkEntry {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let entry = DogWalkEntry(durationInMinutes: durationInMinutes,
                                     humainInteraction: humainInteraction,
                                     dogInteraction: dogInteraction)
        modelContext.insert(entry)
        try modelContext.save()
        
        return entry
    }
    
    @MainActor
    // Set to MainActor, because it is used with OpenIntent
    static func dogWalkEntries(for identifiers: [UUID]) async throws -> [DogWalkEntry] {
        let modelContext = DataModel.shared.modelContainer.mainContext
        let entries = try modelContext.fetch(FetchDescriptor<DogWalkEntry>(predicate: #Predicate { identifiers.contains($0.dogWalkID) }))
        
        return entries
    }

    static func dogEntries(limit: Int) async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<DogWalkEntry>(predicate: #Predicate { _ in true})
        descriptor.fetchLimit = limit
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
    
    static func allDogEntries() async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<DogWalkEntry>(predicate: #Predicate { _ in true})
        let entries = try modelContext.fetch(descriptor)
        
        return entries
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
}

// MARK: - Custom Errors
enum DataModelError: LocalizedError {
    case invalidDuration(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidDuration(let duration):
            return "Invalid duration: \(duration) minutes. Duration must be between 0 and 1440 minutes."
        }
    }
}
