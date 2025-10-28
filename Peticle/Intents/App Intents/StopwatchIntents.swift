//
//  StopwatchIntents.swift
//  Peticle
//
//  Created by Claire on 20/05/2025.
//


import AppIntents

struct StartDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Start a dog walk activity"
    static var description = IntentDescription("Set your goal, and a notification will pop up when it's time to go back")
    
    @Parameter(title: "Goal in minutes")
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
        do {
            try await StopwatchViewModel.shared.saveEntryAndStopActivity()
            return .result(dialog: "Your activity was registered")

        } catch {
            if let intentError = error as? IntentError {
                switch intentError {
                case .message(let message):
                    return .result(dialog: "Something bad happened: \(message)")
                case .noEntity:
                    return .result(dialog: "Something bad happened: Entity No Found")
                }

            } else {
                return .result(dialog: "Something bad happened: \(error.localizedDescription)")
            }
            
        }
    }
}
