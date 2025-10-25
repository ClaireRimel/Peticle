//
//  AddDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import CoreSpotlight

struct AddDogIntent: AppIntent {
    static var title: LocalizedStringResource = "Add a New Dog"
    static var description = IntentDescription("Add a new dog to your pet collection.")
    
    @Parameter(title: "Dog Name", description: "The name of your dog")
    var name: String
    
    @Parameter(title: "Age", description: "The age of your dog in years")
    var age: Int

    static var openAppWhenRun: Bool = true
    
    init() {}
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func perform() async throws -> some ReturnsValue<DogEntity> & ProvidesDialog {
        do {
            let dog = try DataModelHelper.addDog(name: name, imageData: nil, age: age)
            
            // Index the new dog for Spotlight search
            try? await CSSearchableIndex.default().indexAppEntities([dog.entity])
            
            let dialog = IntentDialog("Successfully added \(name) to your pet collection!")
            
            return .result(value: dog.entity, dialog: dialog)
            
        } catch {
            throw IntentError.message("Failed to add dog: \(error.localizedDescription)")
        }
    }
}


