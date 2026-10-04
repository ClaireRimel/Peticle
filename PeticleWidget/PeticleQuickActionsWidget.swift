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
                // Same face as the Live Activity: Habanera in light mode, Alfie in dark.
                Image("QualityGood")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .accessibilityHidden(true)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                Text("\(entry.walkCount)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.peticleBrand)
                Text(entry.walkCount == 1 ? "walk" : "walks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Spacer()

            if entry.isWalking {
                Button(intent: StopDogWalkIntent()) {
                    ActionLabel(title: "Stop Walk", systemImage: "stop.fill")
                }
                .quickActionButtonStyle()
            } else {
                Button(intent: StartDogWalkWithDailyGoalIntent()) {
                    ActionLabel(title: "Start Walk", systemImage: "play.fill")
                }
                .quickActionButtonStyle()
            }
        }
        // Same backdrop as the app's screens: white in light mode, black in dark.
        .containerBackground(.background, for: .widget)
    }
}

private struct ActionLabel: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.peticleOnBrand)
    }
}

private extension View {
    /// Filled brand capsule, like the app's primary button.
    func quickActionButtonStyle() -> some View {
        buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(Color.peticleBrand)
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
