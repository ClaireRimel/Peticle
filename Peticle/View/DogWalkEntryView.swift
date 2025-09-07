//
//  DogWalkEntryView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI
import CoreSpotlight
import SwiftData

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
    @Environment(\.dismiss) var dismiss
   
    @Query private var entries: [DogWalkEntry]
    @Bindable var dogWalkEntry: DogWalkEntry
    var mode: DogWalkEntryViewMode

    @State private var durationInMinute: String = ""

    @State private var textEditorPadding: CGFloat = 0

    init(dogWalkEntry: DogWalkEntry, mode: DogWalkEntryViewMode = .create) {
        self.dogWalkEntry = dogWalkEntry
        self.mode = mode
    }
    
    init(entry: DogWalkEntry, mode: DogWalkEntryViewMode = .edit) {
        // Create a temporary entry that will be replaced in onAppear
        self.dogWalkEntry = entry
        self.mode = mode
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("How will you rate the human interaction?",
                           selection: $dogWalkEntry.humainInteraction) {
                        ForEach(InteractionRating.allCases) { rate in
                            Text(rate.localizedName()).tag(rate)
                        }
                    }
                    
                    Picker("How will you rate the dog interaction?", selection:  $dogWalkEntry.dogInteraction) {
                        ForEach(InteractionRating.allCases) { rate in
                            Text(rate.localizedName()).tag(rate)
                        }
                    }
                }
                .pickerStyle(.menu)

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
            .onAppear {
                durationInMinute = dogWalkEntry.durationInMinutes.description
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mode.buttonTitle()) {
                        Task {
                            await save()
                            dismiss()
                        }
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
    
    @MainActor
    private func save() async {
        dogWalkEntry.durationInMinutes = Int(String(durationInMinute)) ?? 0
        // Only insert for create mode, for edit mode the entry is already managed
        if mode == .create {
            modelContext.insert(dogWalkEntry)
        } else {
            do {
                try await DataModelHelper.modify(entryWalk: dogWalkEntry)
            } catch {
                print("❌ \(error.localizedDescription)")
            }
        }
        try? await CSSearchableIndex.default().indexAppEntities([dogWalkEntry.entity])
        
    }
}
