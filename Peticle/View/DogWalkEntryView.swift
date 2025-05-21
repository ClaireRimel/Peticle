//
//  DogWalkEntryView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

struct DogWalkEntryView: View {
    enum DogWalkEntryViewMode: CaseIterable{
        case edit
        case create

        func buttonTitle() -> String {
            switch self {
            case .edit: return String(localized: "Done", comment: "Button title when done editing dog walk entry")
            case .create: return String(localized: "Add", comment: "Button title when done creating a new dog walk entry")
            }
        }

        func navigationTitle() -> String {
            switch self {
            case .edit: return String(localized: "Edit dog walk Entry", comment: "Navigation title when editing a dog walk entry")
            case .create: return String(localized: "New Dog Walk Entry", comment: "Navigation title when creating a new dog walk entry")
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var dogWalkEntry: DogWalkEntry
    @Environment(\.dismiss) var dismiss
    var mode: DogWalkEntryViewMode
    
    @State private var nbrHumainInteraction: Int
    @State private var humainInteractionRating: InteractionRating
    @State private var nbrDogInteraction: Int
    @State private var dogInteractionRating: InteractionRating
    @State private var durationInMinute: String


    @State private var textEditorPadding: CGFloat = 0

    init(dogWalkEntry: DogWalkEntry, mode: DogWalkEntryViewMode = .create) {
        self.dogWalkEntry = dogWalkEntry
        self.mode = mode
        nbrHumainInteraction = dogWalkEntry.humainInteraction.interactionCount
        humainInteractionRating = dogWalkEntry.humainInteraction.interactionRating
        nbrDogInteraction = dogWalkEntry.dogInteraction.interactionCount
        dogInteractionRating = dogWalkEntry.dogInteraction.interactionRating
        durationInMinute = dogWalkEntry.durationInMinutes.description
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("How many humain did interact with?", selection: $nbrHumainInteraction) {
                        ForEach(0...10, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("How was humain interration this time?", selection: $humainInteractionRating) {
                        ForEach(InteractionRating.allCases) { rate in
                            Text(rate.localizedName())
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("How many dog did interact with?", selection: $nbrDogInteraction) {
                        ForEach(0...10, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("How was dog interration this time?", selection: $dogInteractionRating) {
                        ForEach(InteractionRating.allCases) { rate in
                            Text(rate.localizedName())
                        }
                    }
                    .pickerStyle(.menu)

                }
                
                Section {
                    HStack {
                        TextField("time in minutes",
                                  text: $durationInMinute)
                        .font(.headline)
                        .keyboardType(.numberPad)
                        
                        Text("min")
                    }
                }
                
            }
            .navigationTitle(mode.navigationTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mode.buttonTitle()) {
                        save()
                        
                        
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func save() {
        dogWalkEntry.humainInteraction.interactionCount = nbrHumainInteraction
        dogWalkEntry.humainInteraction.interactionRating = humainInteractionRating
        dogWalkEntry.dogInteraction.interactionCount = nbrDogInteraction
        dogWalkEntry.dogInteraction.interactionRating = dogInteractionRating
        
        dogWalkEntry.durationInMinutes = Int(durationInMinute) ?? 0
        if mode == .create {
            modelContext.insert(dogWalkEntry)
        }
        
        try? modelContext.save()
    }
}
