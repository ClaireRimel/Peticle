//
//  WalkingRecommendationIntent.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import AppIntents
import Foundation

/// ProgressReportingIntent: Reports progress to the system during multi-step walk analysis.
/// The Shortcuts app displays a progress bar as each analysis step completes.
struct WalkingRecommendationIntent: AppIntent, ProgressReportingIntent {
    static var title: LocalizedStringResource = "Should I walk my dog today based on our history?"
    static var description = IntentDescription(
        "Get a personalized walking recommendation based on multi-day analysis of your walking history, patterns, and quality trends."
    )

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        progress.totalUnitCount = 4

        do {
            // Step 1: Load today's walks
            let todayWalks = try await DataModelHelper.walksOfToday()
            try await Task.sleep(for: .milliseconds(400))
            progress.completedUnitCount = 1

            // Step 2: Load historical data
            let yesterdayWalks = try await DataModelHelper.walksOfYesterday()
            let allWalks = try await DataModelHelper.allDogWalkEntries()
            try await Task.sleep(for: .milliseconds(400))
            progress.completedUnitCount = 2

            // Step 3: Analyze patterns
            let thisWeekWalks = filterWalksThisWeek(allWalks)
            let avgDuration = averageDuration(thisWeekWalks)
            let qualityBreakdown = qualityDistribution(thisWeekWalks)
            let streak = consecutiveDaysWithWalks(allWalks)
            try await Task.sleep(for: .milliseconds(400))
            progress.completedUnitCount = 3

            // Step 4: Generate recommendation
            let recommendation = buildRecommendation(
                todayWalks: todayWalks,
                yesterdayWalks: yesterdayWalks,
                weeklyWalks: thisWeekWalks,
                averageDuration: avgDuration,
                qualityBreakdown: qualityBreakdown,
                streak: streak
            )
            try await Task.sleep(for: .milliseconds(300))
            progress.completedUnitCount = 4

            return .result(dialog: IntentDialog("\(recommendation)"))
        } catch {
            return .result(dialog: IntentDialog(
                "Unable to analyze your walking history. Please try again later."
            ))
        }
    }

    // MARK: - Analysis Helpers

    private func filterWalksThisWeek(_ walks: [DogWalkEntry]) -> [DogWalkEntry] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return walks.filter { $0.entryDate >= startOfWeek }
    }

    private func averageDuration(_ walks: [DogWalkEntry]) -> Int {
        guard !walks.isEmpty else { return 0 }
        let total = walks.reduce(0) { $0 + $1.durationInMinutes }
        return total / walks.count
    }

    private func qualityDistribution(_ walks: [DogWalkEntry]) -> [WalkQuality: Int] {
        var distribution: [WalkQuality: Int] = [:]
        for walk in walks {
            distribution[walk.walkQuality, default: 0] += 1
        }
        return distribution
    }

    private func consecutiveDaysWithWalks(_ walks: [DogWalkEntry]) -> Int {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: .now)
        var streak = 0
        let walkDates = Set(walks.map { calendar.startOfDay(for: $0.entryDate) })

        while walkDates.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        return streak
    }

    private func buildRecommendation(
        todayWalks: [DogWalkEntry],
        yesterdayWalks: [DogWalkEntry],
        weeklyWalks: [DogWalkEntry],
        averageDuration: Int,
        qualityBreakdown: [WalkQuality: Int],
        streak: Int
    ) -> String {
        var parts: [String] = []

        if todayWalks.isEmpty {
            parts.append("Your dog hasn\'t been walked today yet -- time to get moving!")
        } else {
            let todayMinutes = todayWalks.reduce(0) { $0 + $1.durationInMinutes }
            parts.append(
                "You\'ve already walked \(todayMinutes) min today across \(todayWalks.count) walk\(todayWalks.count == 1 ? "" : "s")."
            )
        }

        if weeklyWalks.isEmpty {
            parts.append("No walks logged this week. Your pup needs exercise!")
        } else {
            parts.append(
                "This week: \(weeklyWalks.count) walk\(weeklyWalks.count == 1 ? "" : "s"), averaging \(averageDuration) min each."
            )
        }

        let badCount = qualityBreakdown[.bad, default: 0]
        let goodCount = qualityBreakdown[.wonderful, default: 0] + qualityBreakdown[.good, default: 0]
        if badCount > goodCount && !weeklyWalks.isEmpty {
            parts.append("Quality has been low lately -- try a new route!")
        } else if goodCount > 0 {
            parts.append("Walk quality has been great -- keep it up!")
        }

        if streak >= 3 {
            parts.append("Amazing \(streak)-day streak!")
        } else if streak == 0 && todayWalks.isEmpty {
            parts.append("Start a new streak today!")
        }

        if todayWalks.isEmpty {
            parts.append("Recommendation: Yes, go for a walk!")
        } else if todayWalks.reduce(0, { $0 + $1.durationInMinutes }) < averageDuration && averageDuration > 0 {
            parts.append("Recommendation: Consider another short walk to hit your average.")
        } else {
            parts.append("Recommendation: You\'re on track -- well done!")
        }

        return parts.joined(separator: "\n")
    }
}
