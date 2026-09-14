//
//  GlassMetricTile.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Compact stat tile — big number, small label, optional caption.
struct GlassMetricTile: View {
    private let value: String
    private let label: LocalizedStringKey
    private let caption: LocalizedStringKey?
    private let systemImage: String?

    init(value: String, label: LocalizedStringKey, caption: LocalizedStringKey? = nil, systemImage: String? = nil) {
        self.value = value
        self.label = label
        self.caption = caption
        self.systemImage = systemImage
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: PeticleTheme.Spacing.sm) {
                HStack(spacing: PeticleTheme.Spacing.xs) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .imageScale(.medium)
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                    }
                    Text(label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(minHeight: 24, alignment: .leading)

                Text(value)
                    .font(.largeTitle.weight(.bold))
                    .numericContentTransition()
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .frame(minHeight: 41, alignment: .leading)

                // Always reserve the caption row so side-by-side tiles keep the same height.
                Text(caption ?? " ")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .opacity(caption == nil ? 0 : 1)
                    .lineLimit(1)
                    .frame(minHeight: 16, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("GlassMetricTile") {
    HStack(spacing: 12) {
        GlassMetricTile(value: "3", label: "Walks", systemImage: "figure.walk")
        GlassMetricTile(value: "47'", label: "Total time", caption: "Goal: 60'", systemImage: "clock.fill")
    }
    .padding()
}
