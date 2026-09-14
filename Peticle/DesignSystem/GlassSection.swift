//
//  GlassSection.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Settings-style section: a small uppercase header above a Liquid Glass
/// card that groups related rows.
struct GlassSection<Content: View>: View {
    private let header: LocalizedStringKey
    private let interactive: Bool
    private let content: Content

    init(_ header: LocalizedStringKey, interactive: Bool = false, @ViewBuilder content: () -> Content) {
        self.header = header
        self.interactive = interactive
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PeticleTheme.Spacing.sm) {
            Text(header)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, PeticleTheme.Spacing.md)

            content
                .peticleGlass(
                    interactive ? Glass.regular.interactive() : .regular,
                    in: RoundedRectangle(cornerRadius: PeticleTheme.Radius.large, style: .continuous)
                )
        }
    }
}
