//
//  peticleWidgetLiveActivity.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PeticleWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PeticleWidgetAttributes.self) { context in
            let goalEnd = context.state.startDate.addingTimeInterval(Double(context.state.goalTime))

            // Lock screen / banner UI
            HStack(spacing: 16) {
                // Left: icon + label
                VStack(spacing: 4) {
                    Image(systemName: "dog.fill")
                        .font(.title2)
                        .foregroundStyle(.indigo)

                    Text("Walk")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 44)

                // Center: timer + progress
                VStack(spacing: 6) {
                    Text(context.state.startDate, style: .timer)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.indigo)
                        .contentTransition(.numericText())

                    ProgressView(
                        timerInterval: context.state.startDate...goalEnd,
                        countsDown: false
                    ) {
                        // empty label
                    }
                    .tint(.indigo)
                }

                // Right: goal
                VStack(spacing: 4) {
                    Text("Goal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(formatTime(context.state.goalTime))
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .frame(width: 50)
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(Color.primary)

        } dynamicIsland: { context in
            let goalEnd = context.state.startDate.addingTimeInterval(Double(context.state.goalTime))

            return DynamicIsland {
                // MARK: - Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "dog.fill")
                            .font(.title2)
                            .foregroundStyle(.indigo)

                        Text("Dog Walk")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.startDate, style: .timer)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.indigo)
                            .contentTransition(.numericText())

                        Text("Goal: \(formatTime(context.state.goalTime))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(
                        timerInterval: context.state.startDate...goalEnd,
                        countsDown: false
                    ) {
                        // empty label
                    }
                    .tint(.indigo)
                    .padding(.top, 4)
                }

            } compactLeading: {
                Image(systemName: "dog.fill")
                    .foregroundStyle(.indigo)

            } compactTrailing: {
                // Circular progress around the timer digits
                ZStack {
                    ProgressView(
                        timerInterval: context.state.startDate...goalEnd,
                        countsDown: false
                    ) {
                        // empty label
                    }
                    .progressViewStyle(.circular)
                    .tint(.indigo)

                    Text(context.state.startDate, style: .timer)
                        .font(.system(size: 10, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(.indigo)
                }
                .frame(width: 26, height: 26)

            } minimal: {
                ZStack {
                    ProgressView(
                        timerInterval: context.state.startDate...goalEnd,
                        countsDown: false
                    ) {
                        // empty label
                    }
                    .progressViewStyle(.circular)
                    .tint(.indigo)

                    Image(systemName: "dog.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.indigo)
                }
            }
            .widgetURL(URL(string: "peticle://dogwalk"))
            .keylineTint(.indigo)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
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
