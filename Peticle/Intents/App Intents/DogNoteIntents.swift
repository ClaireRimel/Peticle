//
//  DogNoteIntents.swift
//  Peticle
//
//  Each dog's description is exposed as a note with the `.notes` schema
//  (iOS 27), so Siri AI understands "Add 'what an amazing dog' to Alfie's
//  note" with no App Shortcut phrase. One note per dog: its id is the
//  dog's id, its title the dog's name, its content the description.
//

import AppIntents
import SwiftData
import CoreSpotlight
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Entities

/// `.notes.note`: a dog's description, shaped like a note.
@AppEntity(schema: .notes.note)
struct DogNoteEntity {
    static let defaultQuery = DogNoteQuery()

    let id: UUID
    var name: AttributedString
    var content: AttributedString?
    var attachments: [IntentFile]
    var isPinned: Bool
    var creationDate: Date?
    var modificationDate: Date?
    var folder: DogsFolderEntity?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(String(name.characters))",
            subtitle: "\(content.map { String($0.characters) } ?? "")"
        )
    }

    init(_ dog: Dog) {
        id = dog.dogID
        name = AttributedString(dog.name)
        content = dog.dogDescription.map { AttributedString($0) }
        attachments = dog.imageData.map { [IntentFile(data: $0, filename: "\(dog.name).jpg", type: .jpeg)] } ?? []
        isPinned = false
        creationDate = dog.addedDate
        modificationDate = nil
        folder = .dogs
    }
}

/// `.notes.folder`: the schema needs one. A single "Dogs" folder holds
/// every dog's note.
@AppEntity(schema: .notes.folder)
struct DogsFolderEntity {
    static let defaultQuery = DogsFolderQuery()

    let id: String
    var name: String
    var parentFolder: DogsFolderEntity?
    var account: PeticleAccountEntity?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static var dogs: DogsFolderEntity {
        DogsFolderEntity(id: "dogs", name: "Dogs")
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
        parentFolder = nil
        account = .peticle
    }
}

/// `.notes.account`: a single local account.
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

/// Indexed so Siri finds "Alfie's note" by meaning.
extension DogNoteEntity: IndexedEntity {}

// MARK: - Queries

struct DogNoteQuery: EntityStringQuery, IndexedEntityQuery {
    @MainActor
    func entities(for identifiers: [DogNoteEntity.ID]) async throws -> [DogNoteEntity] {
        try DataModelHelper.dogNoteEntities { identifiers.contains($0.dogID) }
    }

    @MainActor
    func suggestedEntities() async throws -> [DogNoteEntity] {
        try DataModelHelper.dogNoteEntities { _ in true }
    }

    @MainActor
    func entities(matching string: String) async throws -> [DogNoteEntity] {
        try DataModelHelper.dogNoteEntities {
            string.localizedCaseInsensitiveContains($0.name) || $0.name.localizedCaseInsensitiveContains(string)
        }
    }

    @MainActor
    func reindexEntities(for identifiers: [DogNoteEntity.ID], indexDescription: CSSearchableIndexDescription) async throws {
        try await CSSearchableIndex.default().indexAppEntities(entities(for: identifiers))
    }

    @MainActor
    func reindexAllEntities(indexDescription: CSSearchableIndexDescription) async throws {
        try await DataModelHelper.reindexAllDogNotes()
    }
}

struct DogsFolderQuery: EntityStringQuery {
    func entities(for identifiers: [DogsFolderEntity.ID]) async throws -> [DogsFolderEntity] {
        identifiers.contains(DogsFolderEntity.dogs.id) ? [.dogs] : []
    }

    func suggestedEntities() async throws -> [DogsFolderEntity] {
        [.dogs]
    }

    func entities(matching string: String) async throws -> [DogsFolderEntity] {
        [.dogs]
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

/// `.notes.appendText`: "Add 'what an amazing dog' to Alfie's note".
/// The text goes at the end of the dog's description.
@AppIntent(schema: .notes.appendText)
struct AppendToDogNoteIntent {
    var content: AttributedString
    var target: DogNoteEntity

    @MainActor
    func perform() async throws -> some ReturnsValue<DogNoteEntity> {
        let addition = String(content.characters)
        let note = try DataModelHelper.updateDog(id: target.id) { dog in
            if let current = dog.dogDescription, !current.isEmpty {
                dog.dogDescription = current + "\n" + addition
            } else {
                dog.dogDescription = addition
            }
        }
        return .result(value: note)
    }
}

/// `.notes.createNote`: "Create a note about Alfie: what an amazing dog".
/// There's one note per dog, so this finds the dog named in the title
/// and adds the content to its description.
@AppIntent(schema: .notes.createNote)
struct CreateDogNoteIntent {
    var name: AttributedString
    var content: AttributedString?
    var attachments: [IntentFile]
    var isPinned: Bool
    var folder: DogsFolderEntity?

    @MainActor
    func perform() async throws -> some ReturnsValue<DogNoteEntity> {
        let title = String(name.characters)
        guard let dogID = try DataModelHelper.dogNoteEntities({ title.localizedCaseInsensitiveContains($0.name) }).first?.id else {
            throw IntentError.message(String(localized: "No dog named \(title)"))
        }
        let addition = content.map { String($0.characters) } ?? ""
        let photo = attachments.lazy.compactMap(DataModelHelper.dogPhotoData).first
        let note = try DataModelHelper.updateDog(id: dogID) { dog in
            if !addition.isEmpty {
                if let current = dog.dogDescription, !current.isEmpty {
                    dog.dogDescription = current + "\n" + addition
                } else {
                    dog.dogDescription = addition
                }
            }
            if let photo { dog.imageData = photo }
        }
        return .result(value: note)
    }
}

/// `.notes.updateNote`: the schema's last intent. A photo attached to a
/// dog's note becomes the dog's photo; the title stays the dog's name.
@AppIntent(schema: .notes.updateNote)
struct UpdateDogNoteIntent {
    var target: DogNoteEntity
    var name: AttributedString?
    var attachments: [IntentFile]?
    var isPinned: Bool?
    var folder: DogsFolderEntity?

    @MainActor
    func perform() async throws -> some ReturnsValue<DogNoteEntity> {
        let photo = attachments?.lazy.compactMap(DataModelHelper.dogPhotoData).first
        let note = try DataModelHelper.updateDog(id: target.id) { dog in
            if let photo { dog.imageData = photo }
        }
        return .result(value: note)
    }
}

/// No delete schema in the `.notes` domain, so this is a plain intent.
/// `DeleteIntent` tells the system it's destructive: Siri asks to confirm.
/// It clears the description; the dog stays.
struct DeleteDogNoteIntent: DeleteIntent {
    static var title: LocalizedStringResource = "Delete Dog Note"
    static var description = IntentDescription("Clear the note (the description) of one of your dogs. The dog stays.")

    @Parameter(title: "Notes", description: "The dog notes to clear", requestValueDialog: "Which dog's note should I delete?")
    var entities: [DogNoteEntity]

    init() {}

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        for note in entities {
            _ = try DataModelHelper.updateDog(id: note.id) { $0.dogDescription = nil }
        }
        let names = entities.map { String($0.name.characters) }.formatted(.list(type: .and))
        return .result(dialog: "Deleted the note of \(names).")
    }
}

// MARK: - Data helpers

extension DataModelHelper {
    /// Entities are built while the ModelContext is alive, so SwiftData values stay readable.
    static func dogNoteEntities(_ isIncluded: (Dog) -> Bool) throws -> [DogNoteEntity] {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let descriptor = FetchDescriptor<Dog>(sortBy: [SortDescriptor(\.addedDate)])
        return try modelContext.fetch(descriptor).filter(isIncluded).map(DogNoteEntity.init)
    }

    static func updateDog(id: UUID, _ change: (Dog) -> Void) throws -> DogNoteEntity {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        var descriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.dogID == id })
        descriptor.fetchLimit = 1
        guard let dog = try modelContext.fetch(descriptor).first else {
            throw IntentError.noEntity
        }
        change(dog)
        try modelContext.save()
        let note = DogNoteEntity(dog)
        let dogEntity = dog.entity
        Task {
            try? await CSSearchableIndex.default().indexAppEntities([note])
            try? await CSSearchableIndex.default().indexAppEntities([dogEntity])
        }
        return note
    }

    static func reindexAllDogNotes() async throws {
        try await CSSearchableIndex.default().indexAppEntities(dogNoteEntities { _ in true })
    }

    /// Only images are kept, downscaled so a photo doesn't bloat the store.
    static func dogPhotoData(from file: IntentFile) -> Data? {
        #if canImport(UIKit)
        // Some files arrive as a URL with no data loaded yet.
        var data = file.data
        if data.isEmpty, let url = file.fileURL {
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            data = (try? Data(contentsOf: url)) ?? Data()
        }
        guard let image = UIImage(data: data) else { return nil }
        let maxSide: CGFloat = 1600
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.8)
        #else
        return nil
        #endif
    }
}
