//
//  DogWalkShortcutsProvider.swift
//  Peticle
//
//  Created by Claire on 20/05/2025.
//

import AppIntents

class DogWalkShortcutsProvider: AppShortcutsProvider {
    /// The color the system uses to display the App Shortcuts in the Shortcuts app. This is currently unused.

    /**
     This sample app contains several examples of different intents, but only the intents this array describes make sense as App Shortcuts.
     Put the App Shortcut most people will use as the first item in the array. This first shortcut shouldn't bring the app to the foreground.
     
     Every phrase that people use to invoke an App Shortcut needs to contain the app name, using the `applicationName` placeholder in the provided
     phrase text, as well as any app name synonyms declared in the `INAlternativeAppNames` key of the app's `Info.plist` file. These phrases are
     localized in a string catalog named `AppShortcuts.xcstrings`.
     */
    static var appShortcuts: [AppShortcut] {
    
        AppShortcut(
            intent: StartDogWalkIntent(),
            phrases: [
                "Start a walk in \(.applicationName)",
                "Start an activity in \(.applicationName)"
            ],
            shortTitle: "Start an activity",
            systemImageName: "timer"
        )

        AppShortcut(
            intent: LatestActivityIntent(),
            phrases: [
                "Show me the last activity in \(.applicationName)",
            ],
            shortTitle: "Show the last activity",
            systemImageName: "eye"
        )
        
        AppShortcut(
            intent: OpenEntryIntent(),
            phrases: [
                "Edit the last walk activity in \(.applicationName)",
                "Edit \(\.$target) in \(.applicationName)"
            ],
            shortTitle: "Edit last activity",
            systemImageName: "pencil.circle"
        )
        
        AppShortcut(
            intent: StopDogWalkIntent(),
            phrases: [
                "Stop a walk in \(.applicationName)",
                "Stop the activity \(.applicationName)"
            ],
            shortTitle: "Stop walk",
            systemImageName: "stop.circle.fill"
        )
        
        AppShortcut(
            intent: DeleteWalkIntent(),
            phrases: [
                "Delete \(\.$walkEntity) walk in \(.applicationName)",
                "Remove walk in \(.applicationName)"
            ],
            shortTitle: "Delete walk",
            systemImageName: "trash.fill")
        
        AppShortcut(
            intent: CheckEntryOfTheDay(),
            phrases: [
                "Check walks of the Day in \(.applicationName)"
            ],
            shortTitle: "Check walks",
            systemImageName: "magnifyingglass")

        
        AppShortcut(
            intent: AddActivityIntent(),
            phrases: [
                "Add an activity in \(.applicationName)",
                "Add an activity of \(\.$duration) in \(.applicationName)"
            ],
            shortTitle: "Add Activity",
            systemImageName: "figure.walk"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor {
        .grayGreen
     }
}
