//
//  ShowDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import SwiftUI
import SwiftData

struct ShowDogIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Dog Information"
    static var description = IntentDescription("Display information about a specific dog or show all your dogs.")

    @Parameter(title: "Dog", description: "The dog to show information for")
    var dog: DogEntity?

    init() {}

    init(dog: DogEntity) {
        self.dog = dog
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        if let selectedDog = dog {
            let dialog = IntentDialog("Here is \(selectedDog.name)")
            return .result(
                dialog: dialog,
                view: DogPortraitView(
                    name: selectedDog.name,
                    subtitle: "\(selectedDog.age) years old",
                    imageData: selectedDog.imageData,
                    diameter: 160
                )
                .frame(maxWidth: .infinity)
                .padding()
            )
        } else {
            // Fetch dogs and extract data in the same ModelContext scope
            let modelContext = ModelContext(DataModel.shared.modelContainer)
            let dogs = try modelContext.fetch(FetchDescriptor<Dog>())
            let dogData = dogs.map { dog in
                (name: dog.name, imageData: dog.imageData)
            }

            if dogData.isEmpty {
                let dialog = IntentDialog("You don't have any dogs registered yet. Are you a cat lover?")
                return .result(
                    dialog: dialog,
                    view: ShowCatView()
                )
            } else {
                let dialog = IntentDialog("Here are all your dogs")
                return .result(
                    dialog: dialog,
                    view: ShowDogsView(dogs: dogData)
                )
            }
        }
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

private struct ShowDogsView: View {
    let dogs: [(name: String, imageData: Data?)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: PeticleTheme.Spacing.md)],
                  spacing: PeticleTheme.Spacing.lg) {
            ForEach(dogs, id: \.name) { dog in
                DogPortraitView(name: dog.name, subtitle: nil, imageData: dog.imageData, diameter: 88)
            }
        }
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
