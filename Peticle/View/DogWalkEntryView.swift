//
//  DogWalkEntryView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI
import AppIntents
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

    /// A binding to a user preference indicating whether they hide the Siri tip.
    @AppStorage("displayQualitySiriTip") private var displayQualitySiriTip: Bool = true

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
            ScrollView {
                VStack(alignment: .leading, spacing: PeticleTheme.Spacing.xl) {
                    VStack(alignment: .leading, spacing: PeticleTheme.Spacing.sm) {
                        Text("How will you rate the walk quality?")
                            .font(.headline.weight(.semibold))
                        WalkQualityPicker(selection: $dogWalkEntry.walkQuality)
                    }

                    GlassSection("Duration") {
                        HStack {
                            TextField("time in minutes",
                                      text: $durationInMinute)
                            .font(.title3.weight(.semibold))
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif

                            Text("min")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .padding(PeticleTheme.Spacing.lg)
                    }

                    #if os(iOS)
                    // SiriTipView: Shows the Siri phrase for updating walk quality
                    SiriTipView(intent: UpdateWalkQualityIntent(), isVisible: $displayQualitySiriTip)
                    #endif
                }
                .padding(.horizontal, PeticleTheme.Spacing.lg)
                .padding(.vertical, PeticleTheme.Spacing.lg)
            }
            .navigationTitle(mode.navigationTitle())
            .onAppear {
                durationInMinute = dogWalkEntry.durationInMinutes.description
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.buttonTitle()) {
                        Task {
                            await save()
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @MainActor
    private func save() async {
        dogWalkEntry.durationInMinutes = Int(String(durationInMinute)) ?? 0
        // Only insert for create mode, for edit mode the entry is already managed
        if mode == .create {
            modelContext.insert(dogWalkEntry)
        } else {
            do {
               _ = try await DataModelHelper.modify(entryWalk: dogWalkEntry)
            } catch {
                print("❌ \(error.localizedDescription)")
            }
            // A real UI action: rating a walk by hand. Siri already knows
            // what people do through Siri and Shortcuts, so only UI
            // interactions are donated.
            let donation = UpdateWalkQualityIntent(walk: dogWalkEntry.entity)
            donation.walkQuality = dogWalkEntry.walkQuality
            _ = try? await donation.donate()
        }
        try? await CSSearchableIndex.default().indexAppEntities([dogWalkEntry.entity])

    }
}
