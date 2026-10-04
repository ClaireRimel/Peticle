//
//  Dog.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import Foundation
import SwiftData

@Model
final class Dog: Identifiable {
    @Attribute(.unique) var dogID: UUID
    var name: String
    var imageData: Data?
    var addedDate: Date
    /// Optional so existing dogs migrate automatically; chosen when adding
    /// a dog, or set with SetDogBreedIntent.
    var breed: Breed?
    /// Free text about the dog, typed in the form or dictated to Siri
    /// ("Add a description to Alfie: …"). Not `description`, which reads
    /// like CustomStringConvertible.
    var dogDescription: String?

    init(
        dogID: UUID = UUID(),
        name: String,
        imageData: Data? = nil,
        addedDate: Date = .now
    ) {
        self.dogID = dogID
        self.name = name
        self.imageData = imageData
        self.addedDate = addedDate
    }
}

extension Dog {
    var entity: DogEntity {
        DogEntity(self)
    }
}
