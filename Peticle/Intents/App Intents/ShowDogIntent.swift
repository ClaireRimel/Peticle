//
//  ShowDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import SwiftUI
import SwiftData
import CoreSpotlight

struct ShowDogIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Dog Information"
    static var description = IntentDescription("Display one of your dogs, optionally of one breed. Without a dog, asks which one.")

    @Parameter(title: "Dog", description: "The dog to show information for")
    var dog: DogEntity?

    /// An AppEnum, so it can be said in a phrase ("Show my labradors").
    @Parameter(title: "Breed", description: "Only show dogs of this breed")
    var breed: Breed?

    init() {}

    init(dog: DogEntity) {
        self.dog = dog
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        // "Show Alfie": the phrase fills the dog. "Show a dog" or "Show my
        // labradors" with several matches: Siri asks which one with
        // requestDisambiguation, listing the dogs with their photo.
        if dog == nil {
            let allDogs = try await DogEntity.defaultQuery.allEntities()
            let dogs = allDogs.filter { breed == nil || $0.breed == breed }
            switch dogs.count {
            case 0 where allDogs.isEmpty:
                return .result(
                    dialog: "You don't have any dogs registered yet. Are you a cat lover?",
                    view: ShowCatView()
                )
            case 0:
                throw IntentError.message(String(localized: "You don't have any \(breed?.localizedName ?? "") yet."))
            case 1:
                dog = dogs.first
            default:
                dog = try await $dog.requestDisambiguation(
                    among: dogs,
                    dialog: "Which dog would you like to see?"
                )
            }
        }

        guard let selectedDog = dog else { throw IntentError.noEntity }
        // Siri says the name and the description; the view is just the photo.
        let dialog: IntentDialog = if let text = selectedDog.dogDescription {
            "Here is \(selectedDog.name). \(text)"
        } else {
            "Here is \(selectedDog.name)"
        }

        return .result(
            dialog: dialog,
            view: DogPhotoView(name: selectedDog.name, imageData: selectedDog.imageData)
                .padding()
        )
    }
}


private struct ShowCatView: View {
    var body: some View {
        Image("love cat")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: PeticleTheme.Radius.large, style: .continuous))
            .padding()
    }
}

/// The dog's photo in a rounded rectangle, or its initial on the brand
/// gradient when there's no photo.
private struct DogPhotoView: View {
    let name: String
    let imageData: Data?

    var body: some View {
        ZStack {
            if let imageData, let image = Image(imageData: imageData) {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [.peticleChocolate, .peticleCaramel],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: 96, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .clipShape(.rect(cornerRadius: PeticleTheme.Radius.xlarge))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(name))
    }
}

/// "Add a description to Alfie: what an amazing dog". The description is
/// free text: Siri asks for it, since a phrase can't carry a String.
struct SetDogDescriptionIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Dog Description"
    static var description = IntentDescription("Add or replace the description of one of your dogs.")

    @Parameter(title: "Dog")
    var dog: DogEntity

    @Parameter(title: "Description", requestValueDialog: "What would you like to say about this dog?")
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("Set the description of \(\.$dog) to \(\.$text)")
    }

    init() {}

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dogID = dog.id
        var descriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.dogID == dogID })
        descriptor.fetchLimit = 1
        guard let model = try modelContext.fetch(descriptor).first else { throw IntentError.noEntity }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        model.dogDescription = trimmed.isEmpty ? nil : trimmed
        try modelContext.save()
        try? await CSSearchableIndex.default().indexAppEntities([model.entity])
        return .result(dialog: "Description added to \(dog.name).")
    }
}

/// Changes a dog's breed, e.g. for a dog added before breeds existed.
struct SetDogBreedIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Breed"
    static var description = IntentDescription("Set the breed of one of your dogs.")

    @Parameter(title: "Dog")
    var dog: DogEntity

    @Parameter(title: "Breed")
    var breed: Breed

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$dog) as \(\.$breed)")
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dogID = dog.id
        var dogDescriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.dogID == dogID })
        dogDescriptor.fetchLimit = 1
        guard let model = try modelContext.fetch(dogDescriptor).first else { throw IntentError.noEntity }
        model.breed = breed
        try modelContext.save()
        DogWalkShortcutsProvider.updateAppShortcutParameters()
        try? await CSSearchableIndex.default().indexAppEntities([model.entity])
        return .result(dialog: "\(dog.name) is now a \(breed.localizedName).")
    }
}
