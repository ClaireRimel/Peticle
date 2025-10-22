//
//  Dog.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import Foundation
import SwiftData

@Model
final class Dog: Identifiable, Sendable {
    @Attribute(.unique) var dogID: UUID
    var name: String
    var imageData: Data?
    var age: Int
    var addedDate: Date
    
    init(
        dogID: UUID = UUID(),
        name: String,
        imageData: Data? = nil,
        age: Int,
        addedDate: Date = .now
    ) {
        self.dogID = dogID
        self.name = name
        self.imageData = imageData
        self.age = max(0, min(age, 30)) // Max 30 years
        self.addedDate = addedDate
    }
}

extension Dog {
    var entity: DogEntity {
        DogEntity(self)
    }
}
