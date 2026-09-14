//
//  WalkQualityPicker.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Hands-easy 4-state picker for `WalkQuality`. Shows the Habanera (light
/// mode) and Alfie (dark mode) illustrations on Liquid Glass tiles.
struct WalkQualityPicker: View {
    @Binding var selection: WalkQuality

    var body: some View {
        HStack(spacing: PeticleTheme.Spacing.sm) {
            ForEach(WalkQuality.displayOrder) { quality in
                qualityButton(for: quality)
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func qualityButton(for quality: WalkQuality) -> some View {
        let isSelected = quality == selection
        let shape = RoundedRectangle(cornerRadius: PeticleTheme.Radius.medium, style: .continuous)

        return Button {
            withAnimation(PeticleTheme.Animation.snappy.reduceMotionAware) {
                selection = quality
            }
        } label: {
            VStack(spacing: PeticleTheme.Spacing.xs) {
                Image(quality.imageAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                    .accessibilityHidden(true)
                Text(quality.label)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PeticleTheme.Spacing.md)
            .peticleGlass(isSelected ? Glass.regular.tint(.peticleBrand.opacity(0.28)) : .regular, in: shape)
            // A border marks the selection without painting over the dog.
            .overlay {
                if isSelected {
                    shape.stroke(Color.peticleBrand, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(quality.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("WalkQualityPicker") {
    @Previewable @State var quality: WalkQuality = .good
    WalkQualityPicker(selection: $quality)
        .padding()
}
