//
//  ShowDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import SwiftUI

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
        if let selectedDog = dog,
           let dogEntry = try await DataModelHelper.dog(for: selectedDog.id) {
            let photo = dogEntry.photo
            let dialog = IntentDialog("Here is \(selectedDog.name)")
            return .result(
                dialog: dialog,
                view: PictureView(dogPicture: photo)
            )
        } else {
            let dogs = try await DataModelHelper.allDogs()
            if dogs.isEmpty {
                let dialog = IntentDialog("You don't have any dogs registered yet. Are you a cat lover?")
                return .result(
                    dialog: dialog,
                    view: ShowCatView()
                )
            } else {
                let photos = dogs.map { (name: $0.name, photo: $0.photo) }
                let dialog = IntentDialog("Here are all your dogs")
                return .result(
                    dialog: dialog,
                    view: ShowDogsView(dogs: photos)
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
            .cornerRadius(10)
    }
}

private struct ShowDogsView: View {
    let dogs: [(name: String, photo: UIImage?)]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(dogs, id: \.name) { dog in
                PictureView(dogPicture: dog.photo)
                    .aspectRatio(contentMode: .fit)
            }
        }
        .padding(.horizontal, 8)
    }
}

private struct PictureView: View {
    let dogPicture: UIImage?

    var body: some View {
        if let dogPicture {
            Image(uiImage: dogPicture)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(10)

        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "camera")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
                .cornerRadius(10)
        }
    }
}
