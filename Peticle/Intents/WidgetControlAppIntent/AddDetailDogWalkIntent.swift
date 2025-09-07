//
//  AddDetailDogWalkIntent.swift
//  Peticle
//
//  Created by Claire on 22/05/2025.
//

import AppIntents

struct AddDetailDogWalkIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Details to the Last Dog Walk Entry"
    
    static var isDiscoverable = false
    
    func perform() async throws -> some OpensIntent {
        return .result(opensIntent: OpenEntryIntent())
    }
}
