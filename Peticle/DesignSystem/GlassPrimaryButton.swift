//
//  GlassPrimaryButton.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Primary call-to-action using the Liquid Glass prominent button style.
/// One per screen; secondary actions use `.buttonStyle(.glass)` directly.
struct GlassPrimaryButton: View {
    private let title: LocalizedStringKey
    private let systemImage: String?
    private let role: ButtonRole?
    private let action: () -> Void

    init(_ title: LocalizedStringKey, systemImage: String? = nil, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }

    var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: PeticleTheme.Spacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PeticleTheme.Spacing.md)
            // White on chocolate in light mode, black on caramel in dark.
            .foregroundStyle(Color.peticleOnBrand)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .tint(Color.peticleBrand)
    }
}

#Preview("GlassPrimaryButton") {
    VStack(spacing: 16) {
        GlassPrimaryButton("Start a walk", systemImage: "play.fill") {}
        GlassPrimaryButton("Stop the walk", systemImage: "stop.fill", role: .destructive) {}
    }
    .padding()
}
