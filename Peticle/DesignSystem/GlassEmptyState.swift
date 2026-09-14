//
//  GlassEmptyState.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Empty state hero inside a Liquid Glass card. Extra content (a Siri tip
/// for instance) goes in the trailing view builder.
struct GlassEmptyState<Accessory: View>: View {
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let systemImage: String
    private let accessory: Accessory

    /// Hero glyph scales with Dynamic Type instead of a fixed 48 pt.
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 48

    init(
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        systemImage: String,
        @ViewBuilder accessory: () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.accessory = accessory()
    }

    var body: some View {
        GlassCard(cornerRadius: PeticleTheme.Radius.xlarge, padding: PeticleTheme.Spacing.xl) {
            VStack(spacing: PeticleTheme.Spacing.lg) {
                Image(systemName: systemImage)
                    .font(.system(size: iconSize))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                VStack(spacing: PeticleTheme.Spacing.sm) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                    if let message {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                accessory
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("GlassEmptyState") {
    GlassEmptyState(
        title: "No walks yet",
        message: "Start a walk with Siri, without taking your phone out.",
        systemImage: "figure.walk.circle.fill"
    )
    .padding()
}
