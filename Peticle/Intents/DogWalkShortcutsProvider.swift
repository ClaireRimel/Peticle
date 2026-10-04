//
//  DogWalkShortcutsProvider.swift
//  Peticle
//
//  Created by Claire on 20/05/2025.
//

import AppIntents

struct DogWalkShortcutsProvider: AppShortcutsProvider {

    /**
     This sample app contains several examples of different intents, but only the intents this array describes make sense as App Shortcuts.
     Put the App Shortcut most people will use as the first item in the array. This first shortcut shouldn't bring the app to the foreground.

     Every phrase that people use to invoke an App Shortcut needs to contain the app name, using the `applicationName` placeholder in the provided
     phrase text, as well as any app name synonyms declared in the `INAlternativeAppNames` key of the app's `Info.plist` file. These phrases are localized in a string catalog named `AppShortcuts.xcstrings`.
     */
    static var appShortcuts: [AppShortcut] {
        #if os(iOS)
        AppShortcut(
            intent: StartDogWalkIntent(),
            phrases: [
                "Start a walk in \(.applicationName)",
                "Start an activity in \(.applicationName)",
                "Begin walking in \(.applicationName)",
                "Start tracking my walk in \(.applicationName)",
                "Start a dog walk in \(.applicationName)",
                "Begin a walk session in \(.applicationName)"
            ],
            shortTitle: "Start an activity",
            systemImageName: "play.fill"
        )

        AppShortcut(
            intent: StopDogWalkIntent(),
            phrases: [
                "Stop a walk in \(.applicationName)",
                "Stop the activity \(.applicationName)",
                "End walk in \(.applicationName)",
                "Finish walk in \(.applicationName)",
                "Stop walking in \(.applicationName)",
                "End walk session in \(.applicationName)",
                "Stop tracking walk in \(.applicationName)"
            ],
            shortTitle: "Stop walk",
            systemImageName: "stop.circle.fill"
        )

        AppShortcut(
            intent: StopAndRateWalkIntent(),
            phrases: [
                "Stop and rate my walk in \(.applicationName)",
                "Stop and update my walk in \(.applicationName)",
                "End and rate my walk in \(.applicationName)",
                "Finish my walk and rate it in \(.applicationName)"
            ],
            shortTitle: "Stop and rate",
            systemImageName: "star.circle.fill"
        )
        #endif

        AppShortcut(
            intent: AddWalkIntent(),
            phrases: [
                "Add an activity in \(.applicationName)",
                "Log a walk in \(.applicationName)",
                "Record a walk in \(.applicationName)"
            ],
            shortTitle: "Add Activity",
            systemImageName: "figure.walk"
        )

        AppShortcut(
            intent: UpdateWalkQualityIntent(),
            phrases: [
                "Update walk quality in \(.applicationName)",
                "Rate my walk in \(.applicationName)",
                "Update walk rating in \(.applicationName)",
                "Change walk quality in \(.applicationName)",
                "Rate walk quality in \(.applicationName)"
            ],
            shortTitle: "Update Walk Quality",
            systemImageName: "arrow.trianglehead.2.clockwise.rotate.90"
        )

        AppShortcut(
            intent: ManageLatestWalkEntryIntent(),
            phrases: [
                "Manage latest walks in \(.applicationName)",
                "Manage recent walks in \(.applicationName)",
                "Manage walk entries in \(.applicationName)",
                "Manage walk records in \(.applicationName)",
                "View walk management in \(.applicationName)",
                "Manage walk data in \(.applicationName)",
                "Manage walk history in \(.applicationName)",
                "Show me my latest walk in \(.applicationName)"
            ],
            shortTitle: "Manage last walks",
            systemImageName: "magnifyingglass")

        AppShortcut(
            intent: ShowDogIntent(),
            phrases: [
                "Show my dogs in \(.applicationName)",
                "Show dog information in \(.applicationName)",
                "Display my dogs in \(.applicationName)",
                "List my dogs in \(.applicationName)",
                "Show dog details in \(.applicationName)",
                "View my dogs in \(.applicationName)",
                "Show a dog in \(.applicationName)",
                "Show my \(\.$breed) in \(.applicationName)",
                "Show a \(\.$breed) in \(.applicationName)",
                "Show \(\.$dog) in \(.applicationName)"
            ],
            shortTitle: "Show Dogs",
            systemImageName: "dog.fill"
        )
    }

    // MARK: - Negative Phrases

    /// NegativeAppShortcutPhrases: Phrases that should NOT trigger this app.
    /// This trains Siri to avoid false positives from similar-sounding commands.
    static var negativeShortcuts: [NegativeAppShortcutPhrases] {
        [
            NegativeAppShortcutPhrases(phrases: [
                "Walk me through",
                "Start walking me through",
                "Show me the dog days",
                "Walk through the steps",
                "Walking directions"
            ])
        ]
    }

    /// Fallback for surfaces that don't read the Info.plist colours
    /// (`ShortcutTint` / `ShortcutAccent`). Closest match to the
    /// chocolate / caramel palette in Apple's fixed enum.
    static var shortcutTileColor: ShortcutTileColor {
        .grayBrown
    }
}
