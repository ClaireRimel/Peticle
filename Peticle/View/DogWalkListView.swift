//
//  DogWalkListView.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import SwiftUI
import SwiftData
import CoreSpotlight
import Collections
import AppIntents

struct DogWalkListView: View {
    @Environment(NavigationManager.self) private var navigation
    @State private var isEditSheetPresented: Bool = false
    @State private var showingHiddenView = false

    var body: some View {
        @Bindable var navigation = navigation
        NavigationStack(path: $navigation.dogWalkNavigationPath) {
            FilteredDogWalkListView(searchTerm: navigation.searchText)
            .navigationTitle("Alfie\'s Chronicle")
            .onShake {
                showingHiddenView = true
            }
            
            .sheet(item: $navigation.dogWalkEntry,
                   onDismiss: {
                navigation.clearDogWalkEntry()
             
            }) { entry in
                DogWalkEntryView(dogWalkEntry: entry, mode: .create)
            }
            
            .sheet(item: $navigation.modifyEntry,
                   onDismiss: {
                navigation.clearDogWalkEntry()
            }) { entry in
                DogWalkEntryView(entry: entry, mode: .edit)
            }
            
            .sheet(isPresented: $navigation.shouldShowSecretFeature) {
                navigation.clearDogWalkEntry()
            } content: {
                AddDogView()
            }
            
            .sheet(isPresented: $showingHiddenView) {
                HiddenView()
            }

        }
    }
}


#Preview {
    DogWalkListView()
}


struct FilteredDogWalkListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DogWalkEntry.entryDate, order: .reverse)
    private var dogWalkEntries: [DogWalkEntry]
    private var isInSearchMode = false
    
    /// A binding to a user preference indicating whether they hide the Siri tip.
    @AppStorage("displaySiriTip") private var displaySiriTip: Bool = true

    /// Read the Focus filter state set by DogWalkingFocus (SetFocusFilterIntent).
    /// When a Focus mode activates with this filter, only today\'s walks are shown.
    @AppStorage("focusFilter_showOnlyTodaysWalks") private var showOnlyTodaysWalks: Bool = false

    @Environment(\.dismissSearch) private var dismissSearch

    /// The entries to display, filtered by Focus mode if active.
    private var displayedEntries: [DogWalkEntry] {
        guard showOnlyTodaysWalks else { return dogWalkEntries }
        let calendar = Calendar.current
        return dogWalkEntries.filter { calendar.isDateInToday($0.entryDate) }
    }

    init(searchTerm: String) {
        if !searchTerm.isEmpty {
            isInSearchMode = true
            _dogWalkEntries = Query(filter: #Predicate<DogWalkEntry> {
                $0.entryDate.description.localizedStandardContains(searchTerm)
            }, sort: \DogWalkEntry.entryDate, order: .reverse)
        }
    }

    static let todayString = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: Date.now)
    }()

    var body: some View {
        let calendar = Calendar.current
        let groupedEntries = OrderedDictionary(grouping: displayedEntries, by: { entry in
            if calendar.isDateInToday(entry.entryDate) { return Self.todayString }
            else { return calendar.startOfDay(for: entry.entryDate).formatted(.relative(presentation: .named)) as String }
        })
        List {
            // Focus filter active banner
            if showOnlyTodaysWalks {
                Section {
                    Label("Focus filter active — showing today only", systemImage: "moon.fill")
                        .font(.caption)
                        .foregroundStyle(.indigo)
                        .listRowBackground(Color.indigo.opacity(0.1))
                }
            }

            ForEach(Array(groupedEntries.keys), id: \.self) { group in
                Section(header: Text(group)) {
                    ForEach(groupedEntries[group] ?? []) { entry in
                        DogWalkEntryCellView(dogWalkEntry: entry)
                            .listRowBackground(Color.indigo.opacity(0.3))

                    }
                    .onDelete { indexSet in
                        deleteEntries(entries: indexSet.map { index in (groupedEntries[group] ?? [])[index] })
                    }

                }
            }
        }
        .overlay {
            if displayedEntries.isEmpty {
                if isInSearchMode {
                    ContentUnavailableView.search
                }
                else {
                    ContentUnavailableView {
                        Label("Start walking", systemImage: "figure.walk.circle.fill")
                    
                    } description: {
                        Text("Keep track of your walks with your dog \nAdd a new entry to get started")
                        
                        /**
                         `SiriTipView` pairs with an intent the system uses as an App Shortcut. It provides a small view with the phrase from the
                         App Shortcut so that people learn they can view their favorite trails quickly by speaking the phrase to Siri with no
                         additional setup. The `isVisible` parameter is optional, but recommended to enable people to hide the view.
                         */
                        SiriTipView(intent: StartDogWalkIntent(), isVisible: $displaySiriTip)
                    }
                }
            }
        }
        .onAppear() {
            modelContext.rollback()
        }
    }

    private func deleteEntries(entries: [DogWalkEntry]) {
        withAnimation {
            entries.forEach { modelContext.delete($0) }
            do {
                try modelContext.save()
            } catch {
                print("Failed to save after deletion: \(error)")
            }
        }
        let ids = entries.map(\.dogWalkID)
    
        Task {
            try? await CSSearchableIndex.default().deleteAppEntities(identifiedBy: ids, ofType: DogWalkEntryEntity.self)
        }

        if let count = try? modelContext.fetchCount(FetchDescriptor<DogWalkEntry>()),
           count == 0 {
            dismissSearch()
        }
    }
}
