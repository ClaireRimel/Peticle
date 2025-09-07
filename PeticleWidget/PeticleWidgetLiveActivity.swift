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
            // Lock screen/banner UI goes here
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "dog.fill")
                        .foregroundColor(context.state.goalTime > context.state.elapsedTime ? .blue : .green)
                    Text("Dog Walk in Progress")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 8) {
                    Text("Elapsed: \(formatTime(context.state.elapsedTime))")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Goal: \(formatTime(context.state.goalTime))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: min(Double(context.state.elapsedTime) / Double(context.state.goalTime), 1.0))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding(.horizontal)
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(Color.primary)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Image(systemName: "dog.fill")
                            .foregroundColor(context.state.goalTime > context.state.elapsedTime ? .blue : .green)
                        Text("Walk")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text(formatTime(context.state.elapsedTime))
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Elapsed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        Text("Goal: \(formatTime(context.state.goalTime))")
                            .font(.subheadline)
                        
                        ProgressView(value: min(Double(context.state.elapsedTime) / Double(context.state.goalTime), 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                }
            } compactLeading: {
                Image(systemName: "dog.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                Text(formatTime(context.state.elapsedTime))
                    .font(.caption)
                    .fontWeight(.medium)
            } minimal: {
                Image(systemName: "dog.fill")
                    .foregroundColor(.blue)
            }
            .widgetURL(URL(string: "peticle://dogwalk"))
            .keylineTint(Color.blue)
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

extension PeticleWidgetAttributes {
    fileprivate static var preview: PeticleWidgetAttributes {
        PeticleWidgetAttributes(walkName: "Morning Walk")
    }
}

public extension PeticleWidgetAttributes.ContentState {
    static var preview: PeticleWidgetAttributes.ContentState {
        .init(elapsedTime: 1800, goalTime: 3600, isActive: true)
    }
}

