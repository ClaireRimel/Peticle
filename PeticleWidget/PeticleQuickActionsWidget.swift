//
//  PeticleQuickActionsWidget.swift
//  peticleWidget
//
//  Created by Claire on 27/02/2026.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Provider

struct QuickActionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickActionsEntry {
        QuickActionsEntry(date: .now, walkCount: 0, isWalking: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickActionsEntry) -> Void) {
        completion(QuickActionsEntry(date: .now, walkCount: 0, isWalking: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionsEntry>) -> Void) {
        Task { @MainActor in
            let count = (try? await DataModelHelper.walksTodayCount()) ?? 0
            let sharedDefaults = UserDefaults(suiteName: "group.com.Yo.Peticle")
            let isWalking = sharedDefaults?.bool(forKey: "isWalking") ?? false
            let entry = QuickActionsEntry(date: .now, walkCount: count, isWalking: isWalking)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

// MARK: - Timeline Entry

struct QuickActionsEntry: TimelineEntry {
    let date: Date
    let walkCount: Int
    let isWalking: Bool
}

// MARK: - Widget View

/// An interactive widget with a Start/Stop button powered by App Intents.
/// The button toggles based on whether a Live Activity is running.
struct QuickActionsWidgetView: View {
    var entry: QuickActionsEntry

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "dog.fill")
                    .font(.title3)
                    .foregroundStyle(.indigo)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                Text("\(entry.walkCount)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.indigo)
                Text(entry.walkCount == 1 ? "walk" : "walks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Spacer()

            if entry.isWalking {
                Button(intent: StopDogWalkIntent()) {
                    Label("Stop Walk", systemImage: "stop.fill")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .tint(.red)
            } else {
                Button(intent: StartDogWalkIntent()) {
                    Label("Start Walk", systemImage: "play.fill")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .tint(.indigo)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration

struct PeticleQuickActionsWidget: Widget {
    static let kind = "com.Yo.Peticle.QuickActions"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: QuickActionsProvider()) { entry in
            QuickActionsWidgetView(entry: entry)
        }
        .configurationDisplayName("Quick Actions")
        .description("See today\'s walk count and quickly start or stop a walk.")
        .supportedFamilies([.systemSmall])
    }
}
