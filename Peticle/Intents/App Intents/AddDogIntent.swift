//
//  AddDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import CoreSpotlight

struct AddDogIntent: AppIntent {
    static var title: LocalizedStringResource = "Add a Dog"
    static var description = IntentDescription("Add a new dog, with its breed.")
    static var suggestedInvocationPhrase: String? = "Add a dog"

    @Parameter(title: "Name", description: "The name of your dog")
    var name: String

    /// An AppEnum, so it can be said in a phrase ("Add a labrador in
    /// Peticle").
    @Parameter(title: "Breed", description: "The breed of your dog")
    var breed: Breed?

    init() {}

    @MainActor
    func perform() async throws -> some ReturnsValue<DogEntity> & ProvidesDialog {
        let chosenBreed: Breed
        if let breed {
            chosenBreed = breed
        } else {
            chosenBreed = try await $breed.requestValue("Which breed is \(name)?")
        }
        let dog = try DataModelHelper.addDog(name: name, imageData: nil, breed: chosenBreed)

        // Index the new dog for Spotlight search
        try? await CSSearchableIndex.default().indexAppEntities([dog.entity])

        return .result(
            value: dog.entity,
            dialog: "\(name) the \(chosenBreed.localizedName) joined your dogs!"
        )
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
