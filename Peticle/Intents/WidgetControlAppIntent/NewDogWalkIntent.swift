//
//  NewDogWalkIntent.swift
//  Peticle
//
//  Created by Claire on 22/05/2025.
//

import AppIntents

struct NewDogWalkIntent: AppIntent {
    static let title: LocalizedStringResource = "Add New Dog Walk Entry"
    
    static var isDiscoverable = false
    
    @Parameter(title: "Dog Walk")
    var target: DogWalkEntryEntity

    func perform() async throws -> some IntentResult {
        return .result(opensIntent: CreateNewDogWalkIIntent(target: $target))
    }
}
