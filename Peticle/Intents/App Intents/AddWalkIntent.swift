//
//  DeleteOrAddWalkIntent.swift
//  Peticle
//
//  Created by Claire on 06/09/2025.
//

import AppIntents
import Foundation
import CoreSpotlight

/// PredictableIntent: Enables the system to proactively suggest this intent based on usage patterns.
/// After each walk is donated, the system learns when the user typically walks and suggests it at the right time.
struct AddWalkIntent: AppIntent, PredictableIntent {
    static var title: LocalizedStringResource = "Log a Quick Dog Walk"
    static var description = IntentDescription("Quickly register a new dog walk with a given duration.")
    
    @Parameter(
        title: "Duration",
        description: "The number of minutes you want to log"
    )
    var duration: Int

    @Parameter(
        title: "Walk Quality",
        description: "The quality rating for how the walk went"
    )
    var walkQuality: WalkQuality

    // MARK: - PredictableIntent

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$duration, \.$walkQuality)) { duration, quality in
            DisplayRepresentation(
                title: "Log a \(duration)-minute walk",
                subtitle: "Quality: \(quality.localizedName())"
            )
        }
        IntentPrediction(parameters: \.$duration) { duration in
            DisplayRepresentation(
                title: "Log a \(duration)-minute walk"
            )
        }
        IntentPrediction {
            DisplayRepresentation(
                title: "Log a Quick Dog Walk"
            )
        }
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let entry = try DataModelHelper.newEntry(durationInMinutes: duration,
                                         walkQuality: walkQuality)

        try? await CSSearchableIndex.default().indexAppEntities([entry.entity])

        return .result(dialog: "Added a new walk of \(duration) minute\(duration == 1 ? "" : "s").")
    }
}
