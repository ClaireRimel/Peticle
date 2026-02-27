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
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "dog.fill")
                        .font(.title3)
                        .foregroundStyle(.indigo)

                    Text("Dog Walk")
                        .font(.headline)

                    Spacer()

                    Text(context.state.startDate, style: .timer)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.indigo)
                        .contentTransition(.numericText())
                    Spacer()
                }

                VStack(spacing: 6) {
                    ProgressView(
                        timerInterval: context.state.startDate...goalEnd,
                        countsDown: false
                    ) {
                        // empty label
                    }
                    .tint(.indigo)

//                    HStack {
//                        Text("0:00")
//                            .font(.caption2)
//                            .foregroundStyle(.secondary)
//                        Spacer()
//                        Text("Goal: \(formatTime(context.state.goalTime))")
//                            .font(.caption2)
//                            .foregroundStyle(.secondary)
//                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(Color.primary)

        } dynamicIsland: { context in
            let goalEnd = context.state.startDate.addingTimeInterval(Double(context.state.goalTime))

            return DynamicIsland {
                // MARK: - Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "dog.fill")
                        .font(.title2)
                        .foregroundStyle(.indigo)
                        .padding(.leading, 2)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.startDate, style: .timer)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.indigo)
                        .contentTransition(.numericText())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text("Goal: \(formatTime(context.state.goalTime))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
