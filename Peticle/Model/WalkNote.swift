//
//  WalkNote.swift
//  Peticle
//

import Foundation
import SwiftData

/// A free-text note written about a walk ("Alfie chased a squirrel").
/// Exposed to Siri and Apple Intelligence through the `.notes` schema domain.
@Model
final class WalkNote: Identifiable {
    @Attribute(.unique) var noteID: UUID
    var name: String
    var content: String
    var isPinned: Bool
    var creationDate: Date
    var modificationDate: Date
    /// The walk this note belongs to, if any.
    var walkID: UUID?
    /// The dog this note is filed under — exposed as a `.notes.folder`.
    var dogID: UUID?

    init(
        noteID: UUID = UUID(),
        name: String,
        content: String = "",
        isPinned: Bool = false,
        creationDate: Date = .now,
        walkID: UUID? = nil,
        dogID: UUID? = nil
    ) {
        self.noteID = noteID
        self.name = name
        self.content = content
        self.isPinned = isPinned
        self.creationDate = creationDate
        self.modificationDate = creationDate
        self.walkID = walkID
        self.dogID = dogID
    }
}
