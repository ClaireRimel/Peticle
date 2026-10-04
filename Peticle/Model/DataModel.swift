//
//  DataModel.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import SwiftData
import WidgetKit
import CoreSpotlight

final class DataModel: Sendable {
    static let shared = DataModel()
    static let appGroupID = "group.com.Yo.Peticle"
    let modelContainer: ModelContainer

    private init() {
        // Explicit App Group store: the app and the widget extension (where
        // the system may run intents for Siri) must read the same walks.
        let configuration = ModelConfiguration(groupContainer: .identifier(Self.appGroupID))
        Self.moveLegacyStoreIfNeeded(to: configuration.url)
        do {
            modelContainer = try ModelContainer(
                for: DogWalkEntry.self, Dog.self, WalkNote.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }

    /// One-time copy of a store created with the default configuration, if it
    /// lived somewhere else. Only the app does it: the extension's own default
    /// store never had the walks. The old files are kept as a backup.
    private static func moveLegacyStoreIfNeeded(to groupURL: URL) {
        let migratedKey = "didMoveStoreToAppGroup"
        guard Bundle.main.bundleURL.pathExtension == "app",
              !UserDefaults.standard.bool(forKey: migratedKey) else { return }
        defer { UserDefaults.standard.set(true, forKey: migratedKey) }

        let legacyURL = ModelConfiguration().url
        let fileManager = FileManager.default
        guard legacyURL.standardizedFileURL != groupURL.standardizedFileURL,
              fileManager.fileExists(atPath: legacyURL.path) else { return }

        try? fileManager.createDirectory(at: groupURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        for suffix in ["", "-shm", "-wal"] {
            let source = URL(fileURLWithPath: legacyURL.path + suffix)
            let destination = URL(fileURLWithPath: groupURL.path + suffix)
            guard fileManager.fileExists(atPath: source.path) else { continue }
            try? fileManager.removeItem(at: destination)
            try? fileManager.copyItem(at: source, to: destination)
        }
    }
}

@MainActor
class DataModelHelper {
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
        index([entry.entity])

        // No donation here: Stop and the intents also save through this
        // helper. Donating AddWalkIntent on every walk taught Siri that
        // "adding a walk" was the main action, so "update walk quality for
        // yesterday" ended up asking for a duration.
        return entry
    }

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
        index([entry.entity])

        return entry
    }

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
            try? await CSSearchableIndex.default().deleteAppEntities(identifiedBy: [identifier], ofType: DogWalkEntryEntity.self)
            WidgetCenter.shared.reloadTimelines(ofKind: "com.Yo.Peticle.QuickActions")

        } else {
            throw DataModelHelperError.noEntryFound(identifier)
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
    
    /// Every walk of a given day, latest first.
    static func walks(on day: Date) async throws -> [DogWalkEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<DogWalkEntry>(
            predicate: #Predicate { $0.entryDate >= startOfDay && $0.entryDate < startOfNextDay },
            sortBy: [SortDescriptor(\.entryDate, order: .reverse)]
        )
        return try ModelContext(DataModel.shared.modelContainer).fetch(descriptor)
    }

    static func lastWalk(on day: Date) async throws -> DogWalkEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        var descriptor = FetchDescriptor<DogWalkEntry>(
            predicate: #Predicate { $0.entryDate >= startOfDay && $0.entryDate < startOfNextDay },
            sortBy: [SortDescriptor(\.entryDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        return try modelContext.fetch(descriptor).first
    }

    static func lastWalkOfToday() async throws -> DogWalkEntry? {
        let walks = try await walksOfToday()
        return walks.sorted(by: { $0.entryDate > $1.entryDate }).first
    }
    
    static func lastWalkOfYesterday() async throws -> DogWalkEntry? {
        let walks = try await walksOfYesterday()
        return walks.sorted(by: { $0.entryDate > $1.entryDate }).first
    }
    
    static func dogWalkEntries(limit: Int) async throws -> [DogWalkEntry] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<DogWalkEntry>(predicate: #Predicate { _ in true})
        descriptor.fetchLimit = limit
        descriptor.sortBy = [SortDescriptor(\.entryDate, order: .reverse)]
        let entries = try modelContext.fetch(descriptor)

        return entries
    }

    /// Pushes walks to Spotlight. Every create / update path goes through
    /// here, so Siri and Spotlight always see the latest walks.
    static func index(_ entities: [DogWalkEntryEntity]) {
        Task {
            try? await CSSearchableIndex.default().indexAppEntities(entities)
        }
    }

    /// Catches up walks saved before indexing covered every path.
    static func reindexAllWalks() async throws {
        let entities = try await allDogWalkEntries().map(\.entity)
        try await CSSearchableIndex.default().indexAppEntities(entities)
    }

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
    case noEntryFound(_ identifier: UUID)

    var errorDescription: String? {
        switch self {
        case .invalidDuration(let duration):
            return "Invalid duration: \(duration) minutes. Duration must be between 0 and 1440 minutes."
        case .noEntryFound(let identifier):
            return "No entry found for the given identifier:\(identifier)"
        }
    }
}
