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
    static var suggestedInvocationPhrase: String? = "Add a dog to my pets"

    @Parameter(title: "Dog Name", description: "The name of your dog")
    var name: String
    
    @Parameter(title: "Age", description: "The age of your dog in years")
    var age: Int

    static var isDiscoverable: Bool = false

    init() {}

    @MainActor
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


struct RemoveDogIntent: AppIntent {
    static var title: LocalizedStringResource = "Remove dog"
    static var description = IntentDescription("Remove a dog from your pet collection.")
    static var suggestedInvocationPhrase: String? = "Remove a dog from my pets"
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Dog",
        description: "Choose the dog to remove"
    )
    var dog: DogEntity

    // Nice, compact summary shown in Shortcuts / Siri UI
    static var parameterSummary: some ParameterSummary {
        Summary("Remove \(\.$dog)")
    }

    init() {}

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        do {
            try await DataModelHelper.deleteDog(for: dog.id)

            let dogName = dog.name
            let dialog = IntentDialog("Successfully removed \(dogName) from your pet collection.")

            return .result(dialog: dialog)
        } catch {
            let dialog = IntentDialog("Failed to remove the dog: \(error.localizedDescription)")

            return .result(dialog: dialog)
        }
    }
}

