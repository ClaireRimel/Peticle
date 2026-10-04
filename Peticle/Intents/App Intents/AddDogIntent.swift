//
//  AddDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import CoreSpotlight

struct AddDogIntent: AppIntent {
    static var title: LocalizedStringResource = "Add a Pet"
    static var description = IntentDescription("Add a new animal to your pets, with an existing species or a new one and its symbol.")
    static var suggestedInvocationPhrase: String? = "Add a pet"

    @Parameter(title: "Name", description: "The name of your animal")
    var name: String

    @Parameter(title: "Age", description: "The age of your animal in years")
    var age: Int

    /// An existing species, created by the user: an AppEntity, so it can be
    /// said in a phrase ("Add a cat in Peticle").
    @Parameter(title: "Species", description: "An existing species, like Dog")
    var species: SpeciesEntity?

    /// To create a species on the fly, with its symbol.
    @Parameter(title: "New Species", description: "The name of a new species, like Cat")
    var newSpeciesName: String?

    /// A fixed list: an AppEnum, shown with icons in Shortcuts.
    @Parameter(title: "Symbol", description: "The symbol of the new species")
    var newSpeciesSymbol: SpeciesSymbol?

    init() {}

    @MainActor
    func perform() async throws -> some ReturnsValue<DogEntity> & ProvidesDialog {
        let chosenSpecies = try await resolveSpecies()
        let dog = try DataModelHelper.addDog(name: name, imageData: nil, age: age, speciesID: chosenSpecies.id)

        // Index the new animal for Spotlight search
        try? await CSSearchableIndex.default().indexAppEntities([dog.entity])

        return .result(
            value: dog.entity,
            dialog: "\(name) the \(chosenSpecies.name.lowercased()) joined your pets!"
        )
    }

    /// Existing species first; else create the new one (asking for its
    /// symbol if missing); else ask which species.
    @MainActor
    private func resolveSpecies() async throws -> SpeciesEntity {
        if let species {
            return species
        }
        if let newSpeciesName, !newSpeciesName.trimmingCharacters(in: .whitespaces).isEmpty {
            let symbol: SpeciesSymbol
            if let newSpeciesSymbol {
                symbol = newSpeciesSymbol
            } else {
                symbol = try await $newSpeciesSymbol.requestValue("Which symbol for \(newSpeciesName)?")
            }
            return try DataModelHelper.createSpecies(name: newSpeciesName, symbol: symbol)
        }
        return try await $species.requestValue("Which species is \(name)?")
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
