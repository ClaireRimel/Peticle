//
//  StopwatchViewModel.swift
//  Peticle
//
//  Created by Claire on 19/05/2025.
//

import Foundation
import WidgetKit
import UserNotifications
import CoreSpotlight
import ActivityKit

@MainActor
@Observable
final class StopwatchViewModel {
    static let shared = StopwatchViewModel()

    var timeElapsed: Int = 0
    var isRunning = false
    private var goalInSeconds: Int = 0
    private var midGoalInSeconds: Int = 0
    private var timer: Timer?
    private var startDate: Date?
    private var currentActivity: Activity<PeticleWidgetAttributes>?

    // MARK: - Persistence Keys
    private enum Keys {
        static let startDate = "stopwatch_startDate"
        static let goalInSeconds = "stopwatch_goalInSeconds"
    }

    /// Shared UserDefaults accessible by both the app and the widget extension.
    static let sharedDefaults = UserDefaults(suiteName: "group.com.Yo.Peticle")

    /// The persisted daily walk goal (in minutes), defaulting to 30 if not set.
    /// Set via SetDailyWalkGoalIntent (SetValueIntent).
    nonisolated static var defaultGoalInMinutes: Int {
        let stored = UserDefaults.standard.integer(forKey: "dailyWalkGoalMinutes")
        return stored > 0 ? stored : 30
    }

    init() {
        requestNotificationPermission()
        restoreState()
    }

    deinit {
        removeScheduledNotification()
    }

    // MARK: - State Persistence

    private func persistState() {
        guard let startDate else { return }
        UserDefaults.standard.set(startDate, forKey: Keys.startDate)
        UserDefaults.standard.set(goalInSeconds, forKey: Keys.goalInSeconds)
    }

    private func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: Keys.startDate)
        UserDefaults.standard.removeObject(forKey: Keys.goalInSeconds)
    }

    private func restoreState() {
        guard let savedStartDate = UserDefaults.standard.object(forKey: Keys.startDate) as? Date else {
            return
        }
        let savedGoal = UserDefaults.standard.integer(forKey: Keys.goalInSeconds)
        guard savedGoal > 0 else { return }

        startDate = savedStartDate
        goalInSeconds = savedGoal
        midGoalInSeconds = savedGoal / 2

        let elapsed = Int(Date.now.timeIntervalSince(savedStartDate))
        timeElapsed = elapsed

        // Reconnect to existing Live Activity if any
        if let existing = Activity<PeticleWidgetAttributes>.activities.first {
            currentActivity = existing
        }

        // If goal not yet reached, resume the timer
        if elapsed < goalInSeconds {
            isRunning = true
            startTimer()
        }
    }

    // MARK: - Live Activity Management

    func isLiveActivityAvailable() -> Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }

    private func endOrphanedActivities() {
        let orphans = Activity<PeticleWidgetAttributes>.activities
        guard !orphans.isEmpty else { return }
        
        Task {
            for activity in orphans {
                let contentState = PeticleWidgetAttributes.ContentState(
                    startDate: .now,
                    goalTime: 0,
                    isActive: false
                )
                await activity.end(
                    .init(state: contentState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
            print("✅ Ended \(orphans.count) orphaned Live Activities")
        }
    }

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("\u{26a0}\u{fe0f} Live Activities are not enabled in Settings")
            return
        }

        guard currentActivity == nil else {
            print("\u{26a0}\u{fe0f} Live Activity is already running")
            return
        }

        guard let startDate else { return }

        let attributes = PeticleWidgetAttributes(walkName: "Dog Walk")
        let contentState = PeticleWidgetAttributes.ContentState(
            startDate: startDate,
            goalTime: goalInSeconds,
            isActive: true
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            print("\u{2705} Live Activity started successfully")
        } catch {
            print("\u{26a0}\u{fe0f} Failed to start Live Activity: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = currentActivity, let startDate else { return }

        let contentState = PeticleWidgetAttributes.ContentState(
            startDate: startDate,
            goalTime: goalInSeconds,
            isActive: isRunning
        )

        Task {
            await activity.update(
                ActivityContent(state: contentState, staleDate: nil)
            )
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity else { return }

        // Clear reference immediately to avoid race conditions
        // when start() is called again before the Task completes
        currentActivity = nil

        let contentState = PeticleWidgetAttributes.ContentState(
            startDate: startDate ?? .now,
            goalTime: goalInSeconds,
            isActive: false
        )

        Task {
            await activity.end(
                .init(state: contentState, staleDate: nil),
                dismissalPolicy: .immediate
            )
            // Also end any orphaned activities from previous sessions
            for orphan in Activity<PeticleWidgetAttributes>.activities {
                await orphan.end(
                    .init(state: contentState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
            print("\u{2705} Live Activity ended")
        }
    }

    // MARK: - Notification Permission
    private func requestNotificationPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
                print("\u{2705} Notification permission granted: \(granted)")
            } catch {
                print("\u{26a0}\u{fe0f} Notification auth error: \(error)")
            }
        }
    }

    // MARK: - Timer Control
    func start(with goalInMinute: Int) {
        // If a walk is already in progress, save it before starting a new one
        if isRunning || startDate != nil || UserDefaults.standard.object(forKey: Keys.startDate) != nil {
            do {
                try saveEntryAndStopActivity()
            } catch {
                // No valid walk to save, just clean up
                isRunning = false
                timer?.invalidate()
                timer = nil
                removeScheduledNotification()
                endLiveActivity()
                clearPersistedState()
                startDate = nil
                timeElapsed = 0
            }
        }
        
        // End any orphaned Live Activities from previous sessions
        endOrphanedActivities()

        let safeGoal = max(1, min(goalInMinute, 1440))

        goalInSeconds = safeGoal * 60
        midGoalInSeconds = goalInSeconds / 2
        isRunning = true
        startDate = .now

        // Persist so state survives background kill
        persistState()

        scheduleNotificationMidTime()
        scheduleCompletionNotification()
        startLiveActivity()
        startTimer()
        Self.sharedDefaults?.set(true, forKey: "isWalking")
        WidgetCenter.shared.reloadTimelines(ofKind: "com.Yo.Peticle.QuickActions")
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }

    private func updateTimer() {
        guard isRunning else { return }
        timeElapsed += 1

        if timeElapsed >= goalInSeconds {
            do {
                try saveEntryAndStopActivity()
            } catch {
                stop()
            }
        }
    }

    private func reset() {
        startDate = nil
        timeElapsed = 0
        clearPersistedState()
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        removeScheduledNotification()
        endLiveActivity()

        Task {
            try? await Task.sleep(for: .seconds(1))
            self.reset()
        }

        Self.sharedDefaults?.set(false, forKey: "isWalking")
        donateEditQualityIntent()
        WidgetCenter.shared.reloadTimelines(ofKind: "com.Yo.Peticle.QuickActions")
    }

    func saveEntryAndStopActivity() throws {
        // Use persisted startDate as source of truth (survives app kill)
        let walkStartDate: Date
        if let saved = UserDefaults.standard.object(forKey: Keys.startDate) as? Date {
            walkStartDate = saved
        } else if let startDate {
            walkStartDate = startDate
        } else {
            throw IntentError.message("No Activity started yet")
        }

        // Restore goal if needed
        if goalInSeconds == 0 {
            goalInSeconds = UserDefaults.standard.integer(forKey: Keys.goalInSeconds)
        }

        // Calculate from persisted start date for accurate duration
        let minutesPassed = max(
            Int(Date.now.timeIntervalSince(walkStartDate)) / 60,
            timeElapsed / 60
        )

        guard minutesPassed > 0 else {
            stop()
            return
        }

        _ = try DataModelHelper.newEntry(durationInMinutes: minutesPassed,
                                         walkQuality: .ok)
        stop()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        updateLiveActivity()
    }

    func resume() {
        guard !isRunning && startDate != nil else { return }
        isRunning = true
        startTimer()
        updateLiveActivity()
    }

    // MARK: - Notifications
    private func scheduleNotificationMidTime() {
        guard midGoalInSeconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Halfway There!"
        content.body = "You're halfway to your goal. Keep going!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(midGoalInSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: "midGoal", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("\u{26a0}\u{fe0f} Failed to schedule mid-goal notification: \(error)")
            }
        }
    }

    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Goal Achieved!"
        content.body = "Congratulations! You've reached your walking goal."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(goalInSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: "goalCompletion", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("\u{26a0}\u{fe0f} Failed to schedule completion notification: \(error)")
            }
        }
    }

    nonisolated private func removeScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["midGoal", "goalCompletion"])
    }

    private func donateEditQualityIntent() {
        Task {
            do {
                if let lastEntry = try await DataModelHelper.lastDogEntry()?.entity {
                    let intent = EditWalkQualityIntent()
                    intent.walkEntity = lastEntry
                    try await intent.donate()
                }
            } catch {
                print("Failed to donate intent: \(error)")
            }
        }
    }

    // MARK: - Public Properties
    var formattedTime: String {
        let hours = timeElapsed / 3600
        let minutes = (timeElapsed % 3600) / 60
        let seconds = timeElapsed % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var progress: Double {
        guard goalInSeconds > 0 else { return 0.0 }
        return min(Double(timeElapsed) / Double(goalInSeconds), 1.0)
    }
}
