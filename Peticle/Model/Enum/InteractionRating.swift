//
//  InteractionRating.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.

import AppIntents
import SwiftUI
import SwiftData

/// An enumeration representing the quality of a dog walk.
enum WalkQuality: String, Codable, CaseIterable, Identifiable, AppEnum, Hashable {
    case ok, bad, good, wonderful

    /// The display name for the enum type, shown in UI elements like pickers.
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Rate the walk quality")

    /// A mapping of each enum case to a localized display representation.
    static var caseDisplayRepresentations: [WalkQuality: DisplayRepresentation] = [
        .ok: DisplayRepresentation(title: LocalizedStringResource("ok", table: "WalkQualityRates")),
        .bad: DisplayRepresentation(title: LocalizedStringResource("bad", table: "WalkQualityRates")),
        .good: DisplayRepresentation(title: LocalizedStringResource("good", table: "WalkQualityRates")),
        .wonderful: DisplayRepresentation(title: LocalizedStringResource("wonderful", table: "WalkQualityRates"))
    ]

    /// Returns the localized name for the quality rating.
    ///
    /// - Returns: A `String` localized from the `WalkQualityRates` strings table.
    func localizedName() -> String {
        String(localized: .init(rawValue), table: "WalkQualityRates")
    }
    
    /// Conformance to `Identifiable` — returns the enum case itself as its identifier.
    var id: Self { self }
}
