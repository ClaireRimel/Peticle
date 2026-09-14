//
//  ActiveWalkCard.swift
//  Peticle
//
//  Ported from Habanera's active walk card.
//

import SwiftUI

/// Live "walk in progress" card, driven by `StopwatchViewModel` — the same
/// model the Start / Stop intents use, so a walk started from Siri shows
/// up here instantly.
struct ActiveWalkCard: View {
    let stopwatch: StopwatchViewModel
    let onStop: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: PeticleTheme.Spacing.md) {
                HStack(spacing: PeticleTheme.Spacing.sm) {
                    Image(systemName: "figure.walk.motion")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    Text("Walk in progress")
                        .font(.headline.weight(.semibold))
                    Spacer()
                }

                Text(stopwatch.formattedTime)
                    .font(.largeTitle.weight(.bold))
                    .monospacedDigit()
                    .numericContentTransition()
                    .frame(maxWidth: .infinity, alignment: .center)

                progressBlock

                GlassPrimaryButton("Stop the walk", systemImage: "stop.fill", role: .destructive, action: onStop)
                    .padding(.top, PeticleTheme.Spacing.xs)
            }
        }
        .sensoryFeedback(.success, trigger: stopwatch.progress >= 1)
    }

    private var progressBlock: some View {
        let goalMinutes = stopwatch.goalInMinutes
        let remainingSeconds = max(0, goalMinutes * 60 - stopwatch.timeElapsed)
        let remainingMinutes = Int((Double(remainingSeconds) / 60).rounded(.up))

        return VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xs) {
            ProgressView(value: stopwatch.progress)
                .tint(.peticleChocolate)

            HStack {
                Text("Goal \(goalMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if stopwatch.progress >= 1 {
                    Text("Goal reached 🎉")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.peticleBrand)
                } else {
                    Text("\(remainingMinutes) min remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .numericContentTransition()
                }
            }
        }
    }
}
