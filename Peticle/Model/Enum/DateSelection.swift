//
//  DateSelection.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import Foundation
import AppIntents

enum DateSelection: String, AppEnum {
    case today
    case yesterday

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Date Selection")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .today: DisplayRepresentation(
            title: LocalizedStringResource( "Today", table: "DateSelection"),
            image: .init(systemName: "calendar")
        ),
        .yesterday: DisplayRepresentation(
            title: LocalizedStringResource( "Yesterday", table: "DateSelection"),
            image: .init(systemName: "calendar")
        )
    ]
    
    /// Returns the last walk entry for the selected date
    @MainActor
    func getLastWalk() async throws -> DogWalkEntry? {
        switch self {
        case .today:
            return try await DataModelHelper.lastWalkOfToday()
        case .yesterday:
            return try await DataModelHelper.lastWalkOfYesterday()
        }
    }
    
    /// Returns all walk entries for the selected date
    func getAllWalks() async throws -> [DogWalkEntry] {
        switch self {
        case .today:
            return try await DataModelHelper.walksOfToday()
        case .yesterday:
            return try await DataModelHelper.walksOfYesterday()
        }
    }
}
