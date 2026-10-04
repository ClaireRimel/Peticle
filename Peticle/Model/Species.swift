//
//  Species.swift
//  Peticle
//
//  A kind of animal the user creates (Dog, Cat…), with the SF Symbol
//  they picked for it. Shared with the widget extension.
//

import Foundation
import SwiftData

@Model
final class Species: Identifiable {
    @Attribute(.unique) var speciesID: UUID
    var name: String
    var symbolName: String
    var createdDate: Date

    /// Deleting a species keeps its animals, without a species.
    @Relationship(deleteRule: .nullify, inverse: \Dog.species)
    var dogs: [Dog] = []

    init(speciesID: UUID = UUID(), name: String, symbolName: String, createdDate: Date = .now) {
        self.speciesID = speciesID
        self.name = name
        self.symbolName = symbolName
        self.createdDate = createdDate
    }
}

extension Species {
    var entity: SpeciesEntity {
        SpeciesEntity(self)
    }
}
