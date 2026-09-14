//
//  ShowDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import SwiftUI
import SwiftData

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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
            let imageData = selectedDog.imageData
            let dialog = IntentDialog("Here is \(selectedDog.name)")
            return .result(
                dialog: dialog,
                view: PictureView(imageData: imageData)
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
            .cornerRadius(10)
    }
}

private struct ShowDogsView: View {
    let dogs: [(name: String, imageData: Data?)]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(dogs, id: \.name) { dog in
                PictureView(imageData: dog.imageData)
                    .aspectRatio(contentMode: .fit)
            }
        }
        .padding(.horizontal, 8)
    }
}

private struct PictureView: View {
    let imageData: Data?

    var body: some View {
        if let imageData, let image = platformImage(from: imageData) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(10)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "camera")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
                .cornerRadius(10)
        }
    }

    private func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #endif
    }
}
