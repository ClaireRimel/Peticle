//
//  PeticleFavoriteWidget.swift
//  peticleWidget
//
//  A configurable widget whose single setting is a @UnionValue (iOS 27):
//  the favorite is a dog OR a walk.
//

import WidgetKit
import SwiftUI
import AppIntents
import SwiftData

// MARK: - Configuration

struct FavoriteConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Favorite"
    static var description = IntentDescription("Show your favorite dog or walk on the Home Screen.")

    /// One setting, two possible types: the widget's edit sheet first asks
    /// "Dog or Walk?", then which one.
    @Parameter(title: "Favorite")
    var favorite: DogOrWalk?
}

// MARK: - Timeline

struct FavoriteEntry: TimelineEntry {
    enum Content {
        case dog(name: String, imageData: Data?)
        case walk(date: Date, durationInMinutes: Int, quality: WalkQuality)
        case none
    }

    let date: Date
    let content: Content
}

struct FavoriteProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> FavoriteEntry {
        FavoriteEntry(date: .now, content: .dog(name: "Alfie", imageData: nil))
    }

    func snapshot(for configuration: FavoriteConfigurationIntent, in context: Context) async -> FavoriteEntry {
        await entry(for: configuration)
    }

    func timeline(for configuration: FavoriteConfigurationIntent, in context: Context) async -> Timeline<FavoriteEntry> {
        // The app reloads timelines when walks change; refresh hourly anyway.
        Timeline(entries: [await entry(for: configuration)], policy: .after(.now.addingTimeInterval(3600)))
    }

    /// Re-reads the store: the configured entity is a snapshot from when the
    /// widget was set up, so a renamed dog or re-rated walk would be stale.
    @MainActor
    private func entry(for configuration: FavoriteConfigurationIntent) async -> FavoriteEntry {
        let content: FavoriteEntry.Content
        switch configuration.favorite {
        case .dog(let dog):
            let modelContext = ModelContext(DataModel.shared.modelContainer)
            let dogID = dog.id
            var descriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.dogID == dogID })
            descriptor.fetchLimit = 1
            if let model = try? modelContext.fetch(descriptor).first {
                content = .dog(name: model.name, imageData: model.imageData)
            } else {
                content = .none
            }
        case .walk(let walk):
            if let model = try? await DataModelHelper.dogWalkEntry(for: walk.id) {
                content = .walk(date: model.entryDate, durationInMinutes: model.durationInMinutes, quality: model.walkQuality)
            } else {
                content = .none
            }
        case nil:
            content = .none
        }
        return FavoriteEntry(date: .now, content: content)
    }
}

// MARK: - View

struct FavoriteWidgetView: View {
    let entry: FavoriteEntry

    var body: some View {
        Group {
            switch entry.content {
            case .dog(let name, let imageData):
                VStack(spacing: PeticleTheme.Spacing.xs) {
                    dogPhoto(imageData, name: name)
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    Text(name)
                        .font(.headline)
                        .lineLimit(1)
                }
            case .walk(let date, let duration, let quality):
                VStack(spacing: PeticleTheme.Spacing.xs) {
                    Image(quality.imageAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .accessibilityLabel(Text(quality.label))
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                        .lineLimit(1)
                    Label("\(duration) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            case .none:
                VStack(spacing: PeticleTheme.Spacing.sm) {
                    Image("QualityGood")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    Text("Pick a dog or a walk")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.background, for: .widget)
    }

    @ViewBuilder
    private func dogPhoto(_ data: Data?, name: String) -> some View {
        if let data, let image = Image(imageData: data) {
            image.resizable().scaledToFill()
        } else {
            ZStack {
                LinearGradient(colors: [.peticleChocolate, .peticleCaramel], startPoint: .topLeading, endPoint: .bottomTrailing)
                Text(String(name.prefix(1)).uppercased())
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Widget

struct PeticleFavoriteWidget: Widget {
    static let kind = "com.Yo.Peticle.Favorite"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: FavoriteConfigurationIntent.self, provider: FavoriteProvider()) { entry in
            FavoriteWidgetView(entry: entry)
        }
        .configurationDisplayName("Favorite")
        .description("Your favorite dog or walk.")
        .supportedFamilies([.systemSmall])
    }
}
