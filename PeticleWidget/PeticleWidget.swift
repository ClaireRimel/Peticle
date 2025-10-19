//
//  peticleWidget.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            walkEntity: nil
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let walkEntity = try? await DataModelHelper.lastDogEntry()?.entity
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            walkEntity: walkEntity
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let walkEntity = try? await DataModelHelper.lastDogEntry()?.entity
        
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            walkEntity:walkEntity
        )

        // Refresh every 15 minutes to keep data current
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        return Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let walkEntity: DogWalkEntryEntity?
}

struct PeticleWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let walkEntity = entry.walkEntity {
            actionFor(walkEntity)
        } else {
            noWalksView
        }
    }
    
    func actionFor(_ walkEntity: DogWalkEntryEntity) -> some View {
        VStack(spacing: 8) {
            // Entry details
            Text("Last Walk:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(walkEntity.date.formatted(date: .abbreviated, time: .omitted))")
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .multilineTextAlignment(.center)

            Text("\(walkEntity.durationInMinutes) min")
                .font(.system(size: 14, weight: .semibold))

            walkEntity.walkQuality?.getWeatherIcon()
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .symbolRenderingMode(.multicolor)
            
            // Action buttons
            VStack(spacing: 6) {
                Button(intent: DeleteWalkIntent(walkEntity: walkEntity)) {
                    Label("Delete", systemImage: "trash")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
                
                Button(intent: OpenEditEntryIntent(target: walkEntity)) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption2)
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(8)
        .background(.indigo.opacity(0.3),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
   
    var noWalksView: some View {
        VStack(spacing: 4) {
            Text("No Walk Today!")
                .font(.caption)
                .fontWeight(.medium)
            Spacer()
            Image("Rotated Alfie")
                .resizable()
                .scaledToFit()
        }
        .padding(8)
    }
}
struct peticleWidget: Widget {
    let kind: String = "peticleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PeticleWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    peticleWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .smiley,
        walkEntity: nil
    )
    SimpleEntry(
        date: .now,
        configuration: .starEyes,
        walkEntity: nil
    )
}
