//
//  StopwatchModel.swift
//  Peticle
//
//  Created by Claire on 19/05/2025.
//

import Foundation
import UserNotifications
import CoreSpotlight

@MainActor
class StopwatchViewModel: ObservableObject {
    static let shared = StopwatchViewModel()
    
    @Published var timeElapsed: Int = 0
    @Published var isRunning = false
    private var goalInSeconds: Int = 0
    private var midGoalInSeconds: Int = 0
    private var timer: Timer?
    private var startDate: Date?
    
    init() {
        requestNotificationPermission()
    }
    
    deinit {
        removeScheduledNotification()
        timer?.invalidate()
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
        
        // Check if goal is reached
        if timeElapsed >= goalInSeconds {
            stop()
        }
    }
    
    private func reset() {
        pause()
        timeElapsed = 0
        removeScheduledNotification()
    }
    
    func stop() {
        guard isRunning else { return }
        
        isRunning = false
        timer?.invalidate()
        timer = nil
    
        // Reset after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.reset()
        }
    }
    
    func saveEntryAndStopActivity() throws {
        guard let startDate else { return }
        let minutesPassed = Calendar.current.dateComponents([.minute], from: startDate, to: .now).minute ?? 0
        
        _ = try DataModelHelper.newEntry(durationInMinutes: minutesPassed,
                                         humainInteraction: .none,
                                         dogInteraction: .none)
        stop()
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        guard !isRunning && startDate != nil else { return }
        isRunning = true
        startTimer()
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
