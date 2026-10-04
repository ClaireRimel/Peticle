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
                    // Happy while walking, wonderful once the goal is reached.
                    // Habanera in light mode, Alfie in dark.
                    Image((stopwatch.isGoalReached ? WalkQuality.wonderful : .good).imageAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
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
        .sensoryFeedback(.success, trigger: stopwatch.isGoalReached)
    }

    private var progressBlock: some View {
        let goalMinutes = stopwatch.goalInMinutes
        // Brand while walking towards the goal, green once it's reached.
        let tint = stopwatch.isGoalReached ? Color.green : Color.peticleBrand

        return VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xs) {
            ProgressView(value: stopwatch.progress)
                .tint(tint)

            HStack {
                Text("Goal \(goalMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                // No "remaining" label: the timer and the goal already say it.
                // Past the goal, the overtime is new information.
                Group {
                    if !stopwatch.isGoalReached {
                        EmptyView()
                    } else if stopwatch.overtimeMinutes == 0 {
                        Text("Goal reached 🎉")
                            .fontWeight(.semibold)
                            .foregroundStyle(tint)
                    } else {
                        Text("+\(stopwatch.overtimeMinutes) min")
                            .fontWeight(.semibold)
                            .foregroundStyle(tint)
                    }
                }
                .font(.caption)
                .numericContentTransition()
            }
        }
        .animation(.default, value: stopwatch.isGoalReached)
    }
}
