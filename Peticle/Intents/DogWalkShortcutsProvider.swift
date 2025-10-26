//
//  DogWalkShortcutsProvider.swift
//  Peticle
//
//  Created by Claire on 20/05/2025.
//

import AppIntents

struct DogWalkShortcutsProvider: AppShortcutsProvider {
    /// The color the system uses to display the App Shortcuts in the Shortcuts app. This is currently unused.

    /**
     This sample app contains several examples of different intents, but only the intents this array describes make sense as App Shortcuts.
     Put the App Shortcut most people will use as the first item in the array. This first shortcut shouldn't bring the app to the foreground.

     Every phrase that people use to invoke an App Shortcut needs to contain the app name, using the `applicationName` placeholder in the provided
     phrase text, as well as any app name synonyms declared in the `INAlternativeAppNames` key of the app's `Info.plist` file. These phrases are localized in a string catalog named `AppShortcuts.xcstrings`.
     */
    static var appShortcuts: [AppShortcut] {
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
            intent: AddWalkIntent(),
            phrases: [
                "Add an activity in \(.applicationName)",
                "Log a walk in \(.applicationName)",
                "Record a walk in \(.applicationName)",
                "Add walk entry in \(.applicationName)",
                "Log walk activity in \(.applicationName)",
                "Record walk session in \(.applicationName)",
                "Add walk record in \(.applicationName)"
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
                "Rate walk quality in \(.applicationName)",
                "Update walk quality for \(\.$dateSelection) in \(.applicationName)",
                "Rate my \(\.$dateSelection) walk in \(.applicationName)",
                "Update \(\.$dateSelection) walk quality in \(.applicationName)",
                "Change \(\.$dateSelection) walk rating in \(.applicationName)"
            ],
            shortTitle: "Update Walk Quality",
            systemImageName: "arrow.trianglehead.2.clockwise.rotate.90"
        )

        AppShortcut(
            intent: SeeLatestActivityIntent(),
            phrases: [
                "Show me the last activity in \(.applicationName)",
                "Show my last walk in \(.applicationName)",
                "What was my last walk in \(.applicationName)",
                "Show recent activity in \(.applicationName)",
                "Display last walk in \(.applicationName)",
                "Show me my latest walk in \(.applicationName)"
            ],
            shortTitle: "Show the last activity",
            systemImageName: "eye"
        )

        AppShortcut(
            intent: ManageLatestWalkEntryIntent(),
            phrases: [
                "Manage lastest walks in \(.applicationName)",
                "Manage recent walks in \(.applicationName)",
                "Manage walk entries in \(.applicationName)",
                "Manage walk records in \(.applicationName)",
                "View walk management in \(.applicationName)",
                "Manage walk data in \(.applicationName)",
                "Manage walk history in \(.applicationName)"
            ],
            shortTitle: "Manage last walks",
            systemImageName: "magnifyingglass")

        AppShortcut(
            intent: OpenEditEntryIntent(),
            phrases: [
                "Edit walk in \(.applicationName)",
                "Modify walk in \(.applicationName)",
                "Change walk details in \(.applicationName)",
                "Update walk in \(.applicationName)",
                "Edit walk entry in \(.applicationName)",
                "Modify walk entry in \(.applicationName)"
            ],
            shortTitle: "Edit activity",
            systemImageName: "pencil.circle"
        )

        AppShortcut(
            intent: ShowDogIntent(),
            phrases: [
                "Show my dogs in \(.applicationName)",
                "Show dog information in \(.applicationName)",
                "Display my dogs in \(.applicationName)",
                "List my dogs in \(.applicationName)",
                "Show dog details in \(.applicationName)",
                "View my dogs in \(.applicationName)",
                "Show \(\.$dog) in \(.applicationName)",
                "Display \(\.$dog) in \(.applicationName)",
                "Show information about \(\.$dog) in \(.applicationName)"
            ],
            shortTitle: "Show Dogs",
            systemImageName: "dog.fill"
        )
    }

    static var shortcutTileColor: ShortcutTileColor {
        .grayGreen
    }
}
