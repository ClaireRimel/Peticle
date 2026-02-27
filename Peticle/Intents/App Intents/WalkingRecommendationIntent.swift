//
//  WalkingRecommendationIntent.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import AppIntents
import Foundation

struct WalkingRecommendationIntent: AppIntent {
    static var title: LocalizedStringResource = "Should I walk my dog today based on our history?"
    static var description = IntentDescription("Get a personalized walking recommendation for your dog's health based on your walking history and patterns.")

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        do {
            let recommendation = try await generateWalkingRecommendation()
            let dialog = IntentDialog("\(recommendation)")

            return .result(dialog: dialog)
        } catch {
            let errorMessage = IntentDialog("Unable to analyze your dog's walking history. Please try again later.")
            return .result(dialog: errorMessage)
        }
    }

    private func generateWalkingRecommendation() async throws -> String {
        // Check if there's a walk registered today
        let todayWalks = try await DataModelHelper.walksOfToday()

        if todayWalks.isEmpty {
            // No walk today - dog needs exercise
            return "Yes! Your dog needs a walk today! Daily exercise is essential for your pup's health and happiness! 🐕"
        } else {
            // Already walked today
            return "Perfect! You've already walked your dog today! Your pup is getting the daily exercise they need! 🎉🐕"
        }
    }
}
