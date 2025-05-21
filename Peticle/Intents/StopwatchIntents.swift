//
//  StopwatchIntents.swift
//  Peticle
//
//  Created by Claire on 20/05/2025.
//


import AppIntents

struct StartDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Start dog walk activity"
    static var description = IntentDescription("Set your goal and a notification will pop up when it time to go back")
    
    @Parameter(title: "Goal in min" )
    var goaltime: Int
    
    func perform() async throws -> some IntentResult {
        StopwatchViewModel.shared.start(with: goaltime)
        return .result()
    }
}

struct PauseDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause dog walk activity"
    static var description = IntentDescription("Pause your activty")
        
    func perform() async throws -> some IntentResult {
        StopwatchViewModel.shared.pause()
        return .result()
    }
}

struct ResumeDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Resume dog walk activity"
    static var description = IntentDescription("Resume your activty")

    func perform() async throws -> some IntentResult {
        StopwatchViewModel.shared.resume()
        return .result()
    }
}

struct StopDogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop dog walk activity"
    static var description = IntentDescription("Stop the activity and save it")
        
    func perform() async throws -> some IntentResult {
        try StopwatchViewModel.shared.stop()
        return .result()
    }
}
