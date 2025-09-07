//
//  StopwatchIntents.swift
//  Peticle
//
//  Created by Claire on 20/05/2025.
//


import AppIntents
import SwiftUI

struct StartDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Start a dog walk activity"
    static var description = IntentDescription("Set your goal, and a notification will pop up when it's time to go back")
    
    @Parameter(title: "Goal in minute")
    var goaltime: Int
    
    func perform() async -> some IntentResult {
        // Start the stopwatch
        await StopwatchViewModel.shared.start(with: goaltime)
        
        return .result()
    }
}

struct StopDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop the current dog walk activity"
    static var description = IntentDescription("Stop the current walk and save the progress")
    
    func perform() async -> some ProvidesDialog {
        // Save and Stop the activity
        do {
            try await StopwatchViewModel.shared.saveEntryAndStopActivity()
            return .result(dialog: "Your activity was registered")

        } catch {
            return .result(dialog: "Something bad happened: \(error.localizedDescription)")
        }
    }
}

struct LatestActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Get the last activity"
    static var description = IntentDescription("Return the last activity")
    
    @MainActor
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity> & ShowsSnippetView {
        
        let dialog = IntentDialog("Here is your last walk data")
        let lastEntry = try await DataModelHelper.lastDogEntry()
        
        return .result(value: lastEntry?.entity ?? DogWalkEntryEntity.init(DogWalkEntry.init(durationInMinutes: 0)), dialog: dialog) {
            
            VStack(alignment: .center) {
                Text(lastEntry?.entryDate.formatted(date: .numeric, time: .omitted) ?? "ooo")
                    .font(.system(size: 64))
                    .padding(10)
                
                lastEntry?.dogInteraction.getFusionnedWeatherIcone(with: lastEntry?.humainInteraction ?? InteractionRating.average)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 33, height: 33)
                    .symbolRenderingMode(.multicolor)
                    .padding(10)
            }
            .background(.green,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}



