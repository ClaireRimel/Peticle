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
    static var description = IntentDescription("Display one of your animals, optionally of one species. Without an animal, asks which one.")

    @Parameter(title: "Dog", description: "The dog to show information for")
    var dog: DogEntity?

    /// Species are created by the user: an AppEntity, which can still be
    /// said in a phrase ("Show my cats") once the system knows them.
    @Parameter(title: "Species", description: "Only show animals of this species")
    var species: SpeciesEntity?

    init() {}

    init(dog: DogEntity) {
        self.dog = dog
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        // "Show Alfie": the phrase fills the dog. "Show a dog" or "Show my
        // cats" with several matches: Siri asks which one with
        // requestDisambiguation, listing the animals with their photo.
        if dog == nil {
            let allDogs = try await DogEntity.defaultQuery.allEntities()
            let dogs = allDogs.filter { species == nil || $0.species?.id == species?.id }
            switch dogs.count {
            case 0 where allDogs.isEmpty:
                return .result(
                    dialog: "You don't have any dogs registered yet. Are you a cat lover?",
                    view: ShowCatView()
                )
            case 0:
                throw IntentError.message(String(localized: "You don't have any \(species?.name ?? "") yet."))
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
        return .result(
            dialog: "Here is \(selectedDog.name)",
            view: DogPortraitView(
                name: selectedDog.name,
                subtitle: "\(selectedDog.age) years old",
                imageData: selectedDog.imageData,
                diameter: 160
            )
            .frame(maxWidth: .infinity)
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

/// Round portrait with the dog's name, like the avatars in the app.
private struct DogPortraitView: View {
    let name: String
    let subtitle: String?
    let imageData: Data?
    let diameter: CGFloat

    var body: some View {
        VStack(spacing: PeticleTheme.Spacing.sm) {
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
                        .font(.system(size: diameter * 0.4, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .overlay {
                Circle().strokeBorder(Color.peticleBrand.opacity(0.4), lineWidth: 2)
            }
            .accessibilityHidden(true)

            Text(name)
                .font(.headline)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Changes an animal's species, e.g. to fix one seeded as "Dog".
struct SetDogSpeciesIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Species"
    static var description = IntentDescription("Set the species of one of your animals.")

    @Parameter(title: "Animal")
    var dog: DogEntity

    @Parameter(title: "Species")
    var species: SpeciesEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$dog) as \(\.$species)")
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let dogID = dog.id
        let speciesID = species.id
        var dogDescriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.dogID == dogID })
        dogDescriptor.fetchLimit = 1
        var speciesDescriptor = FetchDescriptor<Species>(predicate: #Predicate { $0.speciesID == speciesID })
        speciesDescriptor.fetchLimit = 1
        guard let model = try modelContext.fetch(dogDescriptor).first,
              let newSpecies = try modelContext.fetch(speciesDescriptor).first else { throw IntentError.noEntity }
        model.species = newSpecies
        try modelContext.save()
        DogWalkShortcutsProvider.updateAppShortcutParameters()
        try? await CSSearchableIndex.default().indexAppEntities([model.entity])
        return .result(dialog: "\(dog.name) is now a \(species.name).")
    }
}
