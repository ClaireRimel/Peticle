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
    
}
