//
//  SetDailyWalkGoalIntent.swift
//  Peticle
//
//  Created by Claire on 28/02/2026.
//

import AppIntents

/// SetValueIntent: Allows the user to set a persistent daily walk goal via Siri or Shortcuts.
/// The stored value becomes the default goal when starting a new walk with StartDogWalkIntent.
struct SetDailyWalkGoalIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Set Daily Walk Goal"
    static var description = IntentDescription(
        "Set your daily walk goal in minutes. This becomes the default goal when you start a new walk."
    )

    @Parameter(title: "Goal in Minutes", description: "Your daily walk goal in minutes")
    var value: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Set daily walk goal to \(\.$value) minutes")
    }

    init() {}

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        guard value >= 1 && value <= 1440 else {
            throw IntentError.message("Walk goal must be between 1 and 1440 minutes.")
        }

        UserDefaults.standard.set(value, forKey: "dailyWalkGoalMinutes")
        StopwatchViewModel.sharedDefaults?.set(value, forKey: "dailyWalkGoalMinutes")

        return .result(
            dialog: "Your daily walk goal has been set to \(value) minute\(value == 1 ? "" : "s")."
        )
    }
}
