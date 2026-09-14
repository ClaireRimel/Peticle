//
//  GlassCard.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Liquid Glass surface used for grouped content (dog header, walk rows,
/// active walk). Pass `interactive: true` for cards that are themselves
/// tappable so the system renders the Liquid Glass press halo.
struct GlassCard<Content: View>: View {
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let interactive: Bool
    private let content: Content

    init(
        cornerRadius: CGFloat = PeticleTheme.Radius.large,
        padding: CGFloat = PeticleTheme.Spacing.lg,
        interactive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.interactive = interactive
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .peticleGlass(
                interactive ? Glass.regular.interactive() : .regular,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            // Makes empty areas of the card tappable when wrapped in a Button.
            .contentShape(.rect(cornerRadius: cornerRadius))
    }
}

#Preview("GlassCard") {
    VStack(spacing: 16) {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Alfie").font(.title2).bold()
                Text("Golden Retriever").foregroundStyle(.secondary)
            }
        }
        GlassCard(cornerRadius: PeticleTheme.Radius.medium) {
            Label("12 walks this week", systemImage: "figure.walk")
        }
    }
    .padding()
    .background(LinearGradient(colors: [.peticleChocolate, .peticleCaramel], startPoint: .top, endPoint: .bottom))
}
