//
//  CheckDailyGoalIntent.swift
//  Peticle
//
//  Created by Claire on 28/02/2026.
//

import AppIntents

struct CheckDailyGoalIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Daily Walk Goal"
    static var description = IntentDescription(
        "Check if you've reached your daily walk goal based on today's walks."
    )

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let goal = StopwatchViewModel.defaultGoalInMinutes
        let todayWalks = try await DataModelHelper.walksOfToday()
        let totalMinutes = todayWalks.reduce(0) { $0 + $1.durationInMinutes }

        if todayWalks.isEmpty {
            return .result(dialog: "You haven't walked yet today. Your goal is \(goal) minutes — time to get moving!")
        }

        if totalMinutes >= goal {
            let extra = totalMinutes - goal
            if extra > 0 {
                return .result(dialog: "Goal reached! You've walked \(totalMinutes) minutes today, that's \(extra) minutes over your \(goal)-minute goal.")
            }
            return .result(dialog: "Goal reached! You've walked exactly \(goal) minutes today.")
        }

        let remaining = goal - totalMinutes
        return .result(dialog: "Not yet — you've walked \(totalMinutes) minutes out of \(goal). \(remaining) more minute\(remaining == 1 ? "" : "s") to go!")
    }
}
