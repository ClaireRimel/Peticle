//
//  DurationPreset.swift
//  Peticle
//
//  Created by Claire on 21/05/2025.
//

import Foundation
import AppIntents

enum DurationPreset: String, AppEnum {
    case thirty = "30"
    case forty = "40"
    case fifty = "50"
    case sixty = "60"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Duration")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .thirty: "30 minutes",
        .forty: "40 minutes",
        .fifty: "50 minutes",
        .sixty: "1 hour"
    ]

    var minutes: Int {
        Int(rawValue) ?? 0
    }
}

