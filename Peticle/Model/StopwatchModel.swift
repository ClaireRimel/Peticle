//
//  StopwatchModel.swift
//  Peticle
//
//  Created by Claire on 19/05/2025.
//

import Foundation
import UserNotifications
import CoreSpotlight
import ActivityKit

@MainActor
class StopwatchViewModel: ObservableObject {
    static let shared = StopwatchViewModel()
    
    @Published var timeElapsed: Int = 0
    @Published var isRunning = false
    private var goalInSeconds: Int = 0
    private var midGoalInSeconds: Int = 0
    private var timer: Timer?
    private var startDate: Date?
    private var currentActivity: Activity<PeticleWidgetAttributes>?
    
    init() {
        requestNotificationPermission()
    }
    
    deinit {
        removeScheduledNotification()
        timer?.invalidate()
        // Note: We can't call async methods from deinit, so we'll handle this differently
        Task { @MainActor [weak self] in
            self?.endLiveActivity()
        }
    }
    
    // MARK: - Live Activity Management
    
    /// Check if Live Activities are available and properly configured
    func isLiveActivityAvailable() -> Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    /// Get detailed Live Activity status for debugging
    func getLiveActivityStatus() -> String {
        let authInfo = ActivityAuthorizationInfo()
        if authInfo.areActivitiesEnabled {
            return "✅ Live Activities are enabled"
        } else {
            return "❌ Live Activities are disabled - check Settings > Face ID & Passcode > Live Activities"
        }
    }
    
    private func startLiveActivity() {
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled in Settings")
            return
        }
        
        // Check if we already have an active Live Activity
        guard currentActivity == nil else {
            print("⚠️ Live Activity is already running")
            return
        }
        
        let attributes = PeticleWidgetAttributes(walkName: "Dog Walk")
        let contentState = PeticleWidgetAttributes.ContentState(
            elapsedTime: 0,
            goalTime: goalInSeconds,
            isActive: true
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            
            print("✅ Live Activity started successfully")
            updateLiveActivity()
        } catch {
            print("⚠️ Failed to start Live Activity: \(error)")
            
            
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let contentState = PeticleWidgetAttributes.ContentState(
            elapsedTime: timeElapsed,
            goalTime: goalInSeconds,
            isActive: isRunning
        )
        
        Task {
            await activity.update(using: contentState)
        }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let contentState = PeticleWidgetAttributes.ContentState(
            elapsedTime: timeElapsed,
            goalTime: goalInSeconds,
            isActive: false
        )
        
        Task {
            await activity.end(.init(state: contentState, staleDate: nil), dismissalPolicy: .immediate)
            currentActivity = nil
            print("✅ Live Activity ended")
        }
    }
    
    // MARK: - Notification Permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("⚠️ Notification auth error: \(error)")
                } else {
                    print("✅ Notification permission granted: \(granted)")
                }
            }
        }
    }
    
    // MARK: - Timer Control
    func start(with goalInMinute: Int) {
        guard !isRunning else { return }
        
        // Validate input
        let safeGoal = max(1, min(goalInMinute, 1440)) // Between 1 minute and 24 hours
        
        goalInSeconds = safeGoal * 60
        midGoalInSeconds = goalInSeconds / 2
        isRunning = true
        
        scheduleNotificationMidTime()
        scheduleCompletionNotification()
        startLiveActivity()
        
        startDate = .now
        
        startTimer()
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
        
        // Update Live Activity
        updateLiveActivity()
        
        // Check if goal is reached
        if timeElapsed >= goalInSeconds {
            stop()
        }
    }
    
    private func reset() {
        pause()
        startDate = nil
        timeElapsed = 0
        removeScheduledNotification()
        endLiveActivity()
    }
    
    func stop() {
        guard isRunning else { return }
        
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // End Live Activity
        endLiveActivity()
    
        // Reset after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.reset()
        }
    }
    
    func saveEntryAndStopActivity() throws {
        guard let startDate else {
            throw IntentError.message("No Activity started yet")
        }
        
        let minutesPassed = Calendar.current.dateComponents([.minute], from: startDate, to: .now).minute ?? 0
        
        _ = try DataModelHelper.newEntry(durationInMinutes: minutesPassed,
                                         humanInteraction: .none,
                                         dogInteraction: .none)
        stop()
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Update Live Activity to show paused state
        updateLiveActivity()
    }
    
    func resume() {
        guard !isRunning && startDate != nil else { return }
        isRunning = true
        startTimer()
        
        // Update Live Activity to show active state
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
                print("⚠️ Failed to schedule mid-goal notification: \(error)")
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
                print("⚠️ Failed to schedule completion notification: \(error)")
            }
        }
    }
    
    // This method needs to be non-actor-isolated since it's called from deinit
    nonisolated private func removeScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["midGoal", "goalCompletion"])
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


extension StopwatchViewModel {
    func startActivity(timeElapsed: Int, progress: Double) {
        
    }
    
    func updateActivity(timeElapsed: Int, progress: Double) {
        
    }
    
    func endActivity(timeElapsed: Int, progress: Double) {
        
    }
}
