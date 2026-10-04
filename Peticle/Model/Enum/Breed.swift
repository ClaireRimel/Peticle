//
//  Breed.swift
//  Peticle
//
//  Shared with the widget extension.
//

import AppIntents

/// The breeds Peticle knows. A fixed list, so an AppEnum: Siri knows every
/// breed at build time, and "Add a labrador" works with no setup.
enum Breed: String, Codable, CaseIterable, AppEnum {
    case labrador, golden, frenchBulldog, jackRussell

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Breed"

    /// Plural synonyms let "Show my labradors" match.
    static let caseDisplayRepresentations: [Breed: DisplayRepresentation] = [
        .labrador: DisplayRepresentation(title: "Labrador", synonyms: ["Lab", "Labradors"]),
        .golden: DisplayRepresentation(title: "Golden", synonyms: ["Golden Retriever", "Goldens"]),
        .frenchBulldog: DisplayRepresentation(title: "French Bulldog", synonyms: ["Frenchie", "French Bulldogs"]),
        .jackRussell: DisplayRepresentation(title: "Jack Russell", synonyms: ["Jack Russell Terrier", "Jack Russells"]),
    ]

    var localizedName: String {
        String(localized: localizedStringResource)
    }
}
