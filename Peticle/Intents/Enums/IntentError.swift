//
//  IntentError.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import Foundation

enum IntentError: LocalizedError {
    case noEntity
    case message(String)

    var errorDescription: String? {
        switch self {
        case .noEntity: return "No matching entry found."
        case .message(let msg): return msg
        }
    }
}
