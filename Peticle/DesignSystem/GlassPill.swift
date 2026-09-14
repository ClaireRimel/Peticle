//
//  GlassPill.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Compact capsule-shaped Liquid Glass chip for tags and status markers.
struct GlassPill: View {
    private let label: LocalizedStringKey
    private let systemImage: String?
    private let tint: Color?

    init(_ label: LocalizedStringKey, systemImage: String? = nil, tint: Color? = nil) {
        self.label = label
        self.systemImage = systemImage
        self.tint = tint
    }

    var body: some View {
        HStack(spacing: PeticleTheme.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.small)
                    .accessibilityHidden(true)
            }
            Text(label)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, PeticleTheme.Spacing.md)
        .padding(.vertical, PeticleTheme.Spacing.xs + 2)
        .peticleGlass(tint.map { Glass.regular.tint($0) } ?? .regular, in: Capsule())
    }
}

#Preview("GlassPill") {
    HStack {
        GlassPill("Focus", systemImage: "moon.fill", tint: .indigo)
        GlassPill("Walking", systemImage: "figure.walk", tint: .orange)
    }
    .padding()
}
