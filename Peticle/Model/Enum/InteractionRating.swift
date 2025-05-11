//
//  InteractionRating.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.

import AppIntents
import SwiftUI

/// An enumeration representing the quality of an interaction during a dog walk or activity.
enum InteractionRating: String, Codable, CaseIterable, Identifiable, AppEnum {
    case none, bad, average, good

    /// The display name for the enum type, shown in UI elements like pickers.
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Rate the interaction")

    /// A mapping of each enum case to a localized display representation.
    static var caseDisplayRepresentations: [InteractionRating: DisplayRepresentation] = [
        .none: DisplayRepresentation(title: LocalizedStringResource("none", table: "InteractionRates")),
        .bad: DisplayRepresentation(title: LocalizedStringResource("bad", table: "StateInteractionRatessOfMind")),
        .average: DisplayRepresentation(title: LocalizedStringResource("average", table: "InteractionRates")),
        .good: DisplayRepresentation(title: LocalizedStringResource("good", table: "InteractionRates"))
    ]
    
    /// Returns a color associated with the rating, useful for UI display.
    ///
    /// - Returns: A `Color` representing the interaction quality.
    func accentColor() -> Color {
        switch self {
        case .none:
            return .gray
        case .bad:
            return .red
        case .average:
            return .yellow
        case .good:
            return .green
        }
    }
    
    /// Returns the localized name for the rating.
    ///
    /// - Returns: A `String` localized from the `InteractionRates` strings table.
    func localizedName() -> String {
        String(localized: .init(rawValue), table: "InteractionRates")
    }
    
    /// Conformance to `Identifiable` — returns the enum case itself as its identifier.
    var id: Self { self }
}
