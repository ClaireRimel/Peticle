//
//  peticleWidgetLiveActivity.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

/// Live Activity for an in-progress walk, styled after Habanera.
/// Elapsed time and progress derive from `startDate` through
/// `Text(_, style: .timer)` and `ProgressView(timerInterval:)`, so no
/// content updates are needed while walking. The content goes stale when
/// the goal is reached, which re-renders it in green with the overtime.
struct PeticleWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PeticleWidgetAttributes.self) { context in
            // Lock screen / banner UI
            LockScreenView(state: context.state, isGoalReached: context.isGoalReached)

        } dynamicIsland: { context in
            let state = context.state
            let isGoalReached = context.isGoalReached

            return DynamicIsland {
                // MARK: - Expanded View
                DynamicIslandExpandedRegion(.trailing) {
                    WalkFaceView(diameter: 32, isGoalReached: isGoalReached)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(state.startDate, style: .timer)
                            .font(.title.weight(.semibold))
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                        Text(state.captionText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    // Kept minimal so the Stop button fits in the island.
                    VStack(spacing: PeticleTheme.Spacing.sm) {
                        WalkProgressView(state: state, isGoalReached: isGoalReached)
                        StopWalkButton()
                    }
                }

            } compactLeading: {
                WalkFaceView(diameter: 22, isGoalReached: isGoalReached)

            } compactTrailing: {
                if state.goalTime > 0 {
                    WalkProgressView(state: state, isGoalReached: isGoalReached)
                        .progressViewStyle(.circular)
                } else {
                    Text(state.startDate, style: .timer)
                        .font(.caption2)
                        .monospacedDigit()
                        .frame(maxWidth: 60)
                }

            } minimal: {
                if state.goalTime > 0 {
                    WalkProgressView(state: state, isGoalReached: isGoalReached)
                        .progressViewStyle(.circular)
                } else {
                    Image(systemName: "figure.walk.motion")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.peticleCaramel)
                }
            }
            .widgetURL(URL(string: "peticle://dogwalk"))
            .keylineTint(Color.peticleCaramel)
        }
    }
}

// MARK: - Subviews

private struct LockScreenView: View {
    let state: PeticleWidgetAttributes.ContentState
    let isGoalReached: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: PeticleTheme.Spacing.md) {
            HStack(spacing: PeticleTheme.Spacing.md) {
                WalkFaceView(diameter: 44, isGoalReached: isGoalReached)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Walk in progress")
                        .font(.headline)
                        .lineLimit(1)
                    Text(state.captionText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: PeticleTheme.Spacing.sm)

                Text(state.startDate, style: .timer)
                    .font(.title2.weight(.semibold))
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .frame(minWidth: 72, alignment: .trailing)
            }

            VStack(alignment: .trailing, spacing: PeticleTheme.Spacing.xs) {
                WalkProgressView(state: state, isGoalReached: isGoalReached)
                GoalStatusText(state: state, isGoalReached: isGoalReached)
            }

            // Stop without opening the app: StopDogWalkIntent is a LiveActivityIntent
            StopWalkButton()
        }
        .padding()
        // Caramel tint, like Habanera: chocolate got lost in the wallpaper.
        .activityBackgroundTint(Color.peticleCaramel.opacity(0.35))
        .activitySystemActionForegroundColor(Color.peticleBrand)
    }
}

/// Habanera's face in light mode, Alfie's in dark mode:
/// happy while walking, wonderful once the goal is reached.
private struct WalkFaceView: View {
    let diameter: CGFloat
    let isGoalReached: Bool

    var body: some View {
        Image((isGoalReached ? WalkQuality.wonderful : .good).imageAssetName)
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

private struct WalkProgressView: View {
    let state: PeticleWidgetAttributes.ContentState
    let isGoalReached: Bool

    var body: some View {
        if state.goalTime > 0 {
            ProgressView(timerInterval: state.startDate...state.goalEndDate, countsDown: false) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
            // Caramel while walking towards the goal, green once it's reached.
            .tint(isGoalReached ? Color.green : Color.peticleCaramel)
        }
    }
}

/// The time walked past the goal. Nothing before it: the timer and the
/// goal in the caption already tell how much is left.
private struct GoalStatusText: View {
    let state: PeticleWidgetAttributes.ContentState
    let isGoalReached: Bool

    var body: some View {
        if state.goalTime > 0, isGoalReached {
            // Counts up from the goal: the walk keeps going past it.
            Text("+\(Text(timerInterval: state.goalEndDate...Date.distantFuture, countsDown: false))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.green)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private struct StopWalkButton: View {
    var body: some View {
        Button(intent: StopDogWalkIntent()) {
            Label("Stop the walk", systemImage: "stop.fill")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.peticleOnBrand)
        }
        // Filled like the app's button: the default style came out see-through.
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(Color.peticleBrand)
    }
}

private extension ActivityViewContext<PeticleWidgetAttributes> {
    /// The activity goes stale at the goal; the date check covers renders
    /// that happen before the system flags it.
    var isGoalReached: Bool {
        state.goalTime > 0 && (isStale || Date.now >= state.goalEndDate)
    }
}

private extension PeticleWidgetAttributes.ContentState {
    var goalEndDate: Date {
        startDate.addingTimeInterval(Double(goalTime))
    }

    var captionText: String {
        guard goalTime > 0 else { return String(localized: "Walking") }
        return String(localized: "Walking · goal \(goalTime / 60) min")
    }
}

// MARK: - Previews

extension PeticleWidgetAttributes {
    fileprivate static var preview: PeticleWidgetAttributes {
        PeticleWidgetAttributes(walkName: "Morning Walk")
    }
}

public extension PeticleWidgetAttributes.ContentState {
    static var preview: PeticleWidgetAttributes.ContentState {
        .init(startDate: .now.addingTimeInterval(-1800), goalTime: 3600, isActive: true)
    }
}

#Preview("Lock Screen", as: .content, using: PeticleWidgetAttributes.preview) {
    PeticleWidgetLiveActivity()
} contentStates: {
    PeticleWidgetAttributes.ContentState.preview
}

#Preview("Dynamic Island", as: .dynamicIsland(.expanded), using: PeticleWidgetAttributes.preview) {
    PeticleWidgetLiveActivity()
} contentStates: {
    PeticleWidgetAttributes.ContentState.preview
}
