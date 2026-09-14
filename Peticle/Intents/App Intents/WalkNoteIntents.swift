//
//  WalkNoteIntents.swift
//  Peticle
//

import AppIntents
import SwiftData

// MARK: - Entities

/// `.notes.note` (iOS 27): a walk note shaped like a note, so Siri and Apple
/// Intelligence can create, rename, pin and append to it — no App Shortcut phrase.
@AppEntity(schema: .notes.note)
struct WalkNoteEntity {
    static let defaultQuery = WalkNoteQuery()

    let id: UUID
    var name: AttributedString
    var content: AttributedString?
    var attachments: [IntentFile]
    var isPinned: Bool
    var creationDate: Date?
    var modificationDate: Date?
    var folder: DogFolderEntity?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(String(name.characters))",
            subtitle: "\(content.map { String($0.characters) } ?? "")"
        )
    }

    init(_ note: WalkNote, folder: DogFolderEntity?) {
        id = note.noteID
        name = AttributedString(note.name)
        content = note.content.isEmpty ? nil : AttributedString(note.content)
        attachments = []
        isPinned = note.isPinned
        creationDate = note.creationDate
        modificationDate = note.modificationDate
        self.folder = folder
    }
}

/// `.notes.folder`: each dog is a folder, so "add a note to Alfie" files it under Alfie.
@AppEntity(schema: .notes.folder)
struct DogFolderEntity {
    static let defaultQuery = DogFolderQuery()

    let id: UUID
    var name: String
    var parentFolder: DogFolderEntity?
    var account: PeticleAccountEntity?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: .init(systemName: "pawprint.fill"))
    }

    init(_ dog: Dog) {
        id = dog.dogID
        name = dog.name
        parentFolder = nil
        account = .peticle
    }
}

/// `.notes.account`: a single local account that holds every dog folder.
@AppEntity(schema: .notes.account)
struct PeticleAccountEntity {
    static let defaultQuery = PeticleAccountQuery()

    let id: String
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static var peticle: PeticleAccountEntity {
        PeticleAccountEntity(id: "peticle", name: "Peticle")
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - Queries

struct WalkNoteQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [WalkNoteEntity.ID]) async throws -> [WalkNoteEntity] {
        try DataModelHelper.noteEntities { identifiers.contains($0.noteID) }
    }

    @MainActor
    func suggestedEntities() async throws -> [WalkNoteEntity] {
        Array(try DataModelHelper.noteEntities { _ in true }.prefix(5))
    }

    @MainActor
    func entities(matching string: String) async throws -> [WalkNoteEntity] {
        try DataModelHelper.noteEntities {
            $0.name.localizedCaseInsensitiveContains(string) || $0.content.localizedCaseInsensitiveContains(string)
        }
    }
}

/// EntityStringQuery: required by the notes schema so Siri can resolve "Alfie" to a folder.
struct DogFolderQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [DogFolderEntity.ID]) async throws -> [DogFolderEntity] {
        try DataModelHelper.folderEntities().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [DogFolderEntity] {
        try DataModelHelper.folderEntities()
    }

    @MainActor
    func entities(matching string: String) async throws -> [DogFolderEntity] {
        try DataModelHelper.folderEntities().filter { $0.name.localizedCaseInsensitiveContains(string) }
    }
}

struct PeticleAccountQuery: EntityQuery {
    func entities(for identifiers: [PeticleAccountEntity.ID]) async throws -> [PeticleAccountEntity] {
        identifiers.contains(PeticleAccountEntity.peticle.id) ? [.peticle] : []
    }

    func suggestedEntities() async throws -> [PeticleAccountEntity] {
        [.peticle]
    }
}

// MARK: - Intents

/// `.notes.createNote`: "Create a note in Peticle: Alfie chased a squirrel".
/// The note is attached to today's latest walk.
@AppIntent(schema: .notes.createNote)
struct CreateWalkNoteIntent {
    var name: AttributedString
    var content: AttributedString?
    var attachments: [IntentFile]
    var isPinned: Bool
    var folder: DogFolderEntity?

    @MainActor
    func perform() async throws -> some ReturnsValue<WalkNoteEntity> {
        let walkID = try await DataModelHelper.lastWalkOfToday()?.dogWalkID
        let note = try DataModelHelper.createNote(
            name: String(name.characters),
            content: content.map { String($0.characters) } ?? "",
            isPinned: isPinned,
            walkID: walkID,
            dogID: folder?.id
        )
        return .result(value: note)
    }
}

/// `.notes.updateNote`: rename, pin or move a walk note to another dog.
@AppIntent(schema: .notes.updateNote)
struct UpdateWalkNoteIntent {
    var target: WalkNoteEntity
    var name: AttributedString?
    var attachments: [IntentFile]?
    var isPinned: Bool?
    var folder: DogFolderEntity?

    @MainActor
    func perform() async throws -> some ReturnsValue<WalkNoteEntity> {
        let note = try DataModelHelper.updateNote(id: target.id) { note in
            if let name { note.name = String(name.characters) }
            if let isPinned { note.isPinned = isPinned }
            if let folder { note.dogID = folder.id }
        }
        return .result(value: note)
    }
}

/// `.notes.appendText`: "Add 'he found a stick' to my walk note".
@AppIntent(schema: .notes.appendText)
struct AppendToWalkNoteIntent {
    var content: AttributedString
    var target: WalkNoteEntity

    @MainActor
    func perform() async throws -> some ReturnsValue<WalkNoteEntity> {
        let addition = String(content.characters)
        let note = try DataModelHelper.updateNote(id: target.id) { note in
            note.content = note.content.isEmpty ? addition : note.content + "\n" + addition
        }
        return .result(value: note)
    }
}

// MARK: - Data helpers

extension DataModelHelper {
    static func folderEntities() throws -> [DogFolderEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        return try modelContext.fetch(FetchDescriptor<Dog>(sortBy: [SortDescriptor(\.addedDate)])).map(DogFolderEntity.init)
    }

    /// Entities are built while the ModelContext is alive, so SwiftData values stay readable.
    static func noteEntities(where isIncluded: (WalkNote) -> Bool) throws -> [WalkNoteEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<WalkNote>(sortBy: [SortDescriptor(\.modificationDate, order: .reverse)])
        return try modelContext.fetch(descriptor).filter(isIncluded).map { note in
            WalkNoteEntity(note, folder: try folder(for: note.dogID, in: modelContext))
        }
    }

    static func createNote(name: String, content: String, isPinned: Bool, walkID: UUID?, dogID: UUID?) throws -> WalkNoteEntity {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let note = WalkNote(name: name, content: content, isPinned: isPinned, walkID: walkID, dogID: dogID)
        modelContext.insert(note)
        try modelContext.save()
        return WalkNoteEntity(note, folder: try folder(for: dogID, in: modelContext))
    }

    static func updateNote(id: UUID, _ change: (WalkNote) -> Void) throws -> WalkNoteEntity {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<WalkNote>(predicate: #Predicate { $0.noteID == id })
        descriptor.fetchLimit = 1
        guard let note = try modelContext.fetch(descriptor).first else {
            throw IntentError.noEntity
        }
        change(note)
        note.modificationDate = .now
        try modelContext.save()
        return WalkNoteEntity(note, folder: try folder(for: note.dogID, in: modelContext))
    }

    private static func folder(for dogID: UUID?, in modelContext: ModelContext) throws -> DogFolderEntity? {
        guard let dogID else { return nil }
        var descriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.dogID == dogID })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first.map(DogFolderEntity.init)
    }
}
