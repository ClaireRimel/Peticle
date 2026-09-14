//
//  GreetingHero.swift
//  Peticle
//
//  Ported from Habanera's Today screen.
//

import SwiftUI

/// Warm hero at the top of the walk list: dog avatar(s), a salutation
/// that follows the time of day, and a line that reacts to today's walks.
struct GreetingHero: View {
    let dogs: [Dog]
    let walksTodayCount: Int

    var body: some View {
        GlassCard(cornerRadius: PeticleTheme.Radius.xlarge) {
            HStack(spacing: PeticleTheme.Spacing.md) {
                avatar
                VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xs) {
                    Text(salutation)
                        .font(.title3.weight(.bold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text(contextualLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var avatar: some View {
        if dogs.count == 1 {
            DogAvatarView(dog: dogs[0], diameter: 56)
        } else {
            HStack(spacing: -16) {
                ForEach(dogs.prefix(2)) { dog in
                    DogAvatarView(dog: dog, diameter: 44)
                        .overlay(Circle().stroke(.background, lineWidth: 2))
                }
                if dogs.count > 2 {
                    Text("+\(dogs.count - 2)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.peticleOnBrand)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.peticleBrand))
                        .overlay(Circle().stroke(.background, lineWidth: 2))
                }
            }
        }
    }

    private var salutation: String {
        let names = ListFormatter.localizedString(byJoining: dogs.map(\.name))
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return String(localized: "Good morning \(names)")
        case 12..<18: return String(localized: "Hi \(names)")
        default: return String(localized: "Good evening \(names)")
        }
    }

    private var contextualLine: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch (walksTodayCount, hour) {
        case (0, 5..<11):
            return String(localized: "Waiting for the morning walk.")
        case (0, 11..<18):
            return String(localized: "No walk yet. Just say it to Siri!")
        case (0, _):
            return String(localized: "Not too late for one last walk.")
        case (1, _):
            return String(localized: "First walk of the day done ✓")
        default:
            return String(localized: "\(walksTodayCount) walks today, well done!")
        }
    }
}
