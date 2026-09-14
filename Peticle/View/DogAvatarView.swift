//
//  DogAvatarView.swift
//  Peticle
//

import SwiftUI

/// Round dog avatar. Falls back to a chocolate gradient with the dog's
/// initial when no photo has been set yet.
struct DogAvatarView: View {
    let dog: Dog
    var diameter: CGFloat = 56

    var body: some View {
        ZStack {
            if let imageData = dog.imageData, let image = Image(imageData: imageData) {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [.peticleChocolate, .peticleCaramel],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Text(String(dog.name.prefix(1)).uppercased())
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
        .overlay {
            Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}
