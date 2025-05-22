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
    
    func perform() async throws -> some OpensIntent {
        return .result(opensIntent: OpenNewDogWalkIIntent())
    }
}
