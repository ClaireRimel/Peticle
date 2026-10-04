//
//  EditWalkDateSheet.swift
//  Peticle
//

import SwiftUI
import SwiftData
import CoreSpotlight
import WidgetKit

/// Changes when a walk happened, from the row's long-press menu.
struct EditWalkDateSheet: View {
    let entry: DogWalkEntry

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date

    init(entry: DogWalkEntry) {
        self.entry = entry
        _date = State(initialValue: entry.entryDate)
    }

    var body: some View {
        NavigationStack {
            DatePicker("Walk date", selection: $date, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .padding(.horizontal, PeticleTheme.Spacing.lg)
                .navigationTitle("Edit date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) { save() }
                    }
                }
        }
        .presentationDetents([.large])
    }

    private func save() {
        entry.entryDate = date
        do {
            try modelContext.save()
        } catch {
            print("Failed to save the new walk date: \(error)")
        }
        // Keep Spotlight and the widget in sync with the new date.
        let entity = entry.entity
        Task {
            try? await CSSearchableIndex.default().indexAppEntities([entity])
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "com.Yo.Peticle.QuickActions")
        dismiss()
    }
}
