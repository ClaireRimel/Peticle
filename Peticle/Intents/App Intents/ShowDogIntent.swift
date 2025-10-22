//
//  ShowDogIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents

struct ShowDogIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Dog Information"
    static var description = IntentDescription("Display information about a specific dog or show all your dogs.")
    
    @Parameter(title: "Dog", description: "The dog to show information for")
    var dog: DogEntity?


    init() {}
    
    init(dog: DogEntity?) {
        self.dog = dog
    }
    
    @MainActor
    func perform() async throws -> some ProvidesDialog {
        if let selectedDog = dog {
            // Show specific dog information
            let dialog = IntentDialog("""
            🐕 \(selectedDog.name)
            Age: \(selectedDog.age) years old
            Added: \(selectedDog.addedDate.formatted(date: .abbreviated, time: .omitted))
            """)
            return .result(dialog: dialog)
        } else {
            // Show all dogs
            let allDogs = try await DataModelHelper.allDogs()
            
            if allDogs.isEmpty {
                let dialog = IntentDialog("You don't have any dogs registered yet. Shake your phone to add your first dog! 🐕")
                return .result(dialog: dialog)
            } else {
                let dogList = allDogs.map { dog in
                    "🐕 \(dog.name) (\(dog.age) years old)"
                }.joined(separator: "\n")
                
                let dialog = IntentDialog("""
                Your Dogs (\(allDogs.count) total):
                
                \(dogList)
                """)
                return .result(dialog: dialog)
            }
        }
    }
}
