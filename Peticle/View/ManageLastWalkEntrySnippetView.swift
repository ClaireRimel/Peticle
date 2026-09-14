//
//  ManageLastWalkEntrySnippetView.swift
//  Peticle
//
//  Created by Claire on 06/09/2025.
//

import AppIntents
import SwiftUI

struct ManageLastWalkEntrySnippetView: View {
    let walkEntity: DogWalkEntryEntity?

    var body: some View {
        if let walkEntity {
            actionFor(walkEntity)
        } else {
            noWalksView
        }
    }

    func actionFor(_ walkEntity: DogWalkEntryEntity) -> some View {
        let currentQuality = walkEntity.walkQuality ?? .ok

        return VStack(spacing: PeticleTheme.Spacing.md) {
            // Hero face: changes with the rating, animated when the snippet redraws
            Image(currentQuality.imageAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .id(currentQuality)
                .transition(.scale(scale: 0.6).combined(with: .opacity))
                .accessibilityHidden(true)

            Text(walkEntity.date, format: .dateTime.hour().minute())
                .font(.subheadline)
                .foregroundStyle(.secondary)

            durationStepper(for: walkEntity)

            // Quality buttons: each tap runs RateWalkIntent, then the snippet redraws.
            // Sized to their label so "Wonderful" never truncates.
            HStack(spacing: PeticleTheme.Spacing.xs) {
                ForEach(WalkQuality.displayOrder) { quality in
                    qualityButton(quality, for: walkEntity, isSelected: quality == currentQuality)
                }
            }

            Button(intent: DeleteWalkIntent(walkEntity: walkEntity)) {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .animation(PeticleTheme.Animation.bouncy, value: currentQuality)
        .animation(PeticleTheme.Animation.snappy, value: walkEntity.durationInMinutes)
    }

    /// −1 / +1 min buttons: a second interactive control whose number rolls on redraw.
    private func durationStepper(for walkEntity: DogWalkEntryEntity) -> some View {
        HStack(spacing: PeticleTheme.Spacing.lg) {
            Button(intent: AdjustWalkDurationIntent(walkEntity: walkEntity, minutes: -1)) {
                Image(systemName: "minus")
                    .font(.headline)
                    .frame(width: 32, height: 32)
            }
            .disabled(walkEntity.durationInMinutes == 0)
            .accessibilityLabel("Remove 1 minute")

            Text("\(walkEntity.durationInMinutes) min")
                .font(.title.weight(.bold))
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(walkEntity.durationInMinutes)))
                .frame(minWidth: 100)

            Button(intent: AdjustWalkDurationIntent(walkEntity: walkEntity, minutes: 1)) {
                Image(systemName: "plus")
                    .font(.headline)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("Add 1 minute")
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(.peticleBrand)
    }

    private func qualityButton(_ quality: WalkQuality, for walkEntity: DogWalkEntryEntity, isSelected: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: PeticleTheme.Radius.medium, style: .continuous)

        return Button(intent: RateWalkIntent(walkEntity: walkEntity, walkQuality: quality)) {
            Text(quality.label)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, PeticleTheme.Spacing.md)
                .padding(.vertical, PeticleTheme.Spacing.sm)
                .background(isSelected ? Color.peticleBrand.opacity(0.2) : Color.secondary.opacity(0.12), in: shape)
                .overlay {
                    if isSelected {
                        shape.stroke(Color.peticleBrand, lineWidth: 2)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    var noWalksView: some View {
        VStack(spacing: PeticleTheme.Spacing.md) {
            Image("Rotated Alfie")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 160)
                .clipShape(RoundedRectangle(cornerRadius: PeticleTheme.Radius.large, style: .continuous))
                .accessibilityHidden(true)
            Text("WHAT?! No Walk Today!!!")
                .font(.title3.weight(.bold))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
