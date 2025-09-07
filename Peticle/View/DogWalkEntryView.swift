//
//  DogWalkEntryView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI
import CoreSpotlight

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
    
    @State private var humainInteractionRating: InteractionRating
    @State private var dogInteractionRating: InteractionRating
    @State private var durationInMinute: String


    @State private var textEditorPadding: CGFloat = 0

    init(dogWalkEntry: DogWalkEntry, mode: DogWalkEntryViewMode = .create) {
        self.dogWalkEntry = dogWalkEntry
        self.mode = mode
        humainInteractionRating = dogWalkEntry.humainInteraction
        dogInteractionRating = dogWalkEntry.dogInteraction
        durationInMinute = dogWalkEntry.durationInMinutes.description
    }
    
    var body: some View {
        NavigationStack {
            Form {
                AnimalInteractionView(humainInteractionRating: humainInteractionRating,
                                      dogInteractionRating: dogInteractionRating)
                
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
                        
                        Task {
                            try? await CSSearchableIndex.default().indexAppEntities([dogWalkEntry.entity])
                        }
                        
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
        dogWalkEntry.humainInteraction = humainInteractionRating
        dogWalkEntry.dogInteraction = dogInteractionRating
        
        dogWalkEntry.durationInMinutes = Int(durationInMinute) ?? 0
        if mode == .create {
            modelContext.insert(dogWalkEntry)
        }
        
        try? modelContext.save()
    }
}

struct AnimalInteractionView: View {
    @State private var humainInteractionRating: InteractionRating
    @State private var dogInteractionRating: InteractionRating
    
    init(humainInteractionRating: InteractionRating, dogInteractionRating: InteractionRating) {
        self.humainInteractionRating = humainInteractionRating
        self.dogInteractionRating = dogInteractionRating
    }
    
    var body: some View {
        Section {
            Picker("How will you rate the human interaction?", selection: $humainInteractionRating) {
                ForEach(InteractionRating.allCases) { rate in
                    Text(rate.localizedName())
                }
            }
            .pickerStyle(.menu)
            
            Picker("How will you rate the dog interaction?", selection: $dogInteractionRating) {
                ForEach(InteractionRating.allCases) { rate in
                    Text(rate.localizedName())
                }
            }
            .pickerStyle(.menu)

        }
    }
}
