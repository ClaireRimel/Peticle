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
        "Set your daily walk goal. This becomes the default goal when you start a new walk."
    )

    /// A duration Measurement, like StartDogWalkIntent's goal: a native
    /// duration picker in Shortcuts, and "an hour" works with Siri.
    @Parameter(
        title: "Goal",
        description: "Your daily walk goal",
        defaultUnit: .minutes,
        supportsNegativeNumbers: false
    )
    var value: Measurement<UnitDuration>

    static var parameterSummary: some ParameterSummary {
        Summary("Set daily walk goal to \(\.$value)")
    }

    init() {}

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let minutes = Int(value.converted(to: .minutes).value.rounded())
        guard minutes >= 1 && minutes <= 1440 else {
            throw IntentError.message("Walk goal must be between 1 minute and 24 hours.")
        }

        UserDefaults.standard.set(minutes, forKey: "dailyWalkGoalMinutes")
        StopwatchViewModel.sharedDefaults?.set(minutes, forKey: "dailyWalkGoalMinutes")

        return .result(
            dialog: "Your daily walk goal has been set to \(minutes) minute\(minutes == 1 ? "" : "s")."
        )
    }
}
