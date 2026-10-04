//
//  DogOrWalk.swift
//  Peticle
//
//  Shared with the widget extension: the Favorite widget is configured
//  with it, and ShowDogOrWalkIntent takes it as a parameter.
//

import AppIntents

/// One parameter, two possible types: a dog OR a walk.
/// Shortcuts first asks "Dog or Walk?", then which one.
@UnionValue
enum DogOrWalk {
    case dog(DogEntity)
    case walk(DogWalkEntryEntity)
}

extension DogOrWalk {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Dog or walk" }

    static let caseDisplayRepresentations: [Cases: DisplayRepresentation] = [
        .dog: "Dog",
        .walk: "Walk",
    ]
}
