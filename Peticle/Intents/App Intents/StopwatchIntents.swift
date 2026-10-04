//
//  StopwatchIntents.swift
//  Peticle
//
//  Created by Claire on 20/05/2025.
//

#if os(iOS)
import AppIntents

struct StartDogWalkIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start a dog walk activity"
    static var description = IntentDescription("Set your goal, and a notification will pop up when it's time to go back")

    /// A Swift `Duration` (App Intents, iOS 26+): a time span with a native
    /// duration picker, and Siri understands "half an hour".
    /// SetDailyWalkGoalIntent still uses Measurement<UnitDuration>, to compare.
    @Parameter(
        title: "Goal",
        defaultUnit: .minutes,
        requestValueDialog: "How long would you like to walk?"
    )
    var goal: Duration

    func perform() async -> some IntentResult {
        let minutes = Int((Double(goal.components.seconds) / 60).rounded())
        await StopwatchViewModel.shared.start(with: minutes)

        return .result()
    }
}

/// Widget version of Start: a widget button can't ask for the goal, so this
/// one uses the daily goal. It runs in the app (LiveActivityIntent), where
/// the daily goal is stored.
struct StartDogWalkWithDailyGoalIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start a dog walk with the daily goal"
    static var description = IntentDescription("Start a walk using your daily walk goal")
    static let isDiscoverable = false

    func perform() async -> some IntentResult {
        await StopwatchViewModel.shared.start(with: StopwatchViewModel.defaultGoalInMinutes)

        return .result()
    }
}

struct StopDogWalkIntent: LiveActivityIntent {
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

/// Stops the walk, then chains into rating it. The plain Stop intent
/// doesn't chain: only this one returns `OpensIntent`, so the follow-up
/// happens only when people ask for it.
struct StopAndRateWalkIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop and rate the current dog walk"
    static var description = IntentDescription("Stop the current walk, save it, then rate how it went")

    func perform() async throws -> some ProvidesDialog & OpensIntent {
        guard let walk = try await StopwatchViewModel.shared.saveEntryAndStopActivity() else {
            throw IntentError.message("The walk was too short to be saved")
        }

        // The system runs the returned intent next: it asks for the quality
        // of the walk that was just saved.
        return .result(
            opensIntent: UpdateWalkQualityIntent(walk: walk.entity),
            dialog: "Your walk was registered"
        )
    }
}
#endif
