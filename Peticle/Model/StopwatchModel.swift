//
//  StopwatchModel.swift
//  Peticle
//
//  Created by Claire on 19/05/2025.
//

import Foundation
import UserNotifications
import CoreSpotlight

class StopwatchViewModel: ObservableObject {
    static let shared = StopwatchViewModel()
    
    @Published var timeElapsed: Int = 0
    @Published var isRunning = false
    private var goalInSeconds: Int = 0
    private var midGoalInSecound: Int = 0
    private var timer: Timer?
    private var startDate: Date?

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("⚠️ Notification auth error: \(error)")
            } else {
                print("✅ Notification permission granted: \(granted)")
            }
        }
    }
    
    deinit {
        removeScheduledNotification()
    }
    
    func start(with goalInMinute: Int) {
        guard !isRunning else { return }
        
        goalInSeconds = goalInMinute * 60
        midGoalInSecound = goalInSeconds/2
        isRunning = true
        
        scheduleNotificationMidTime()
        startDate = .now
    }
    
    // sert à rien
    func pause() {
        timer?.invalidate()
        isRunning = false
    }
    
    // sert à rien
    func resume() {
        guard !isRunning else { return }

        isRunning = false
    }
    
    private func reset() {
        pause()
        timeElapsed = 0
        removeScheduledNotification()
    }
    
    func stop() throws {
        guard let startDate else { return }
        let minutesPassed = Calendar.current.dateComponents([.minute], from: startDate, to: .now).minute ?? 0

        let newEntry = try DataModelHelper.newEntry(durationInMinutes: minutesPassed,
                                         humainInteraction: InteractionEntity(interactionCount: 0,
                                                                              interactionRating: .none),
                                         dogInteraction: InteractionEntity(interactionCount: 0,
                                                                           interactionRating: .none))
        Task {
            try? await CSSearchableIndex.default().indexAppEntities([newEntry.entity])
        }

        reset()
    }
    
    private func scheduleNotificationMidTime() {
        let content = UNMutableNotificationContent()
        content.title = "Time to go back"
        content.body = "You've reached your stopwatch goal of \(goalInSeconds/60) minutes"
        content.sound = .defaultRingtone
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(midGoalInSecound - timeElapsed), repeats: false)
        let request = UNNotificationRequest(identifier: "goalReach", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func removeScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["goalReach"])
    }
}
