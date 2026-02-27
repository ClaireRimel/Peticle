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
        QuickActionsEntry(date: .now, walkCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickActionsEntry) -> Void) {
        completion(QuickActionsEntry(date: .now, walkCount: 0))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionsEntry>) -> Void) {
        Task { @MainActor in
            let count = (try? await DataModelHelper.walksTodayCount()) ?? 0
            let entry = QuickActionsEntry(date: .now, walkCount: count)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

// MARK: - Timeline Entry

struct QuickActionsEntry: TimelineEntry {
    let date: Date
    let walkCount: Int
}

// MARK: - Widget View

/// An interactive widget with a "Start Walk" button powered by App Intents.
/// Button(intent:) allows the widget to trigger intents without opening the app.
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

            Button(intent: StartDogWalkIntent()) {
                Label("Start Walk", systemImage: "play.fill")
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .tint(.indigo)
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
        .description("See today\'s walk count and quickly start a walk.")
        .supportedFamilies([.systemSmall])
    }
}
