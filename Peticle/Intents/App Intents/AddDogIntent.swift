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


struct RemoveDogIntent: DeleteIntent {
    static var title: LocalizedStringResource = "Remove dog"
    static var description = IntentDescription("Remove a dog from your pet collection.")
    static var suggestedInvocationPhrase: String? = "Remove a dog from my pets"
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Dogs",
        description: "Choose the dogs to remove"
    )
    var entities: [DogEntity]

    static var parameterSummary: some ParameterSummary {
        Summary("Remove \(\.$entities)")
    }

    init() {}

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        do {
            for dog in entities {
                try await DataModelHelper.deleteDog(for: dog.id)
            }

            let names = entities.map(\.name).joined(separator: ", ")
            let dialog = IntentDialog("Successfully removed \(names) from your pet collection.")

            return .result(dialog: dialog)
        } catch {
            throw IntentError.message("Failed to remove dog: \(error.localizedDescription)")
        }
    }
}
