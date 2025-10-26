//
//  LatestActivityIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import SwiftUI

struct SeeLatestActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Get the last activity"
    static var description = IntentDescription("Return the last activity")

    @MainActor
    func perform() async throws -> some ReturnsValue<DogWalkEntryEntity> & ShowsSnippetView {
        guard let lastEntry = try await DataModelHelper.lastDogEntry() else {
            throw IntentError.noEntity
        }

        return .result(
            value: lastEntry.entity,
            view: LatestActivitySnippetView(entry: lastEntry)
        )
    }
}

private struct LatestActivitySnippetView: View {
    let entry: DogWalkEntry

    var body: some View {
        VStack(alignment: .center) {
            EntryDateView(date: entry.entryDate)
            DurationView(minutes: entry.durationInMinutes)
            WeatherIconView(icon: entry.walkQuality.getWeatherIcon())
        }
        .padding(24)
        .background(
            .indigo.opacity(0.3),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

private struct EntryDateView: View {
    let date: Date

    var body: some View {
        Text("\(date.formatted(date: .long, time: .omitted))")
            .font(.system(size: 32))
            .foregroundStyle(.white)
    }
}

private struct DurationView: View {
    let minutes: Int

    var body: some View {
        Text("\(minutes) mins")
            .font(.system(size: 22))
            .foregroundStyle(.white)
    }
}

private struct WeatherIconView: View {
    let icon: Image

    var body: some View {
        icon
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .symbolRenderingMode(.multicolor)
    }
}
