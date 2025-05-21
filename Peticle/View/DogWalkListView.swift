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

struct DogWalkListView: View {
    @Environment(NavigationManager.self) private var navigation
    @State private var isEditSheetPresented: Bool = false

    var body: some View {
        @Bindable var navigation = navigation
        NavigationStack(path: $navigation.dogWalkNavigationPath) {
            FilteredDogWalkListView(searchTerm: navigation.searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigation.composeNewDogWalkEntry()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("AppIntentsDogWalk")
            
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
                DogWalkEntryView(dogWalkEntry: entry, mode: .edit)
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

    @Environment(\.dismissSearch) private var dismissSearch

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
        let groupedEntries = OrderedDictionary(grouping: dogWalkEntries, by: { entry in
            if calendar.isDateInToday(entry.entryDate) { return Self.todayString }
            else { return calendar.startOfDay(for: entry.entryDate).formatted(.relative(presentation: .named)) as String }
        })
        List {
            ForEach(Array(groupedEntries.keys), id: \.self) { group in
                Section(header: Text(group)) {
                    ForEach(groupedEntries[group] ?? []) { entry in
                        DogWalkEntryCellView(dogWalkEntry: entry)
                            .listRowBackground(Color.green.opacity(0.1))

                    }
                    .onDelete { indexSet in
                        deleteEntries(entries: indexSet.map { index in (groupedEntries[group] ?? [])[index] })
                    }

                }
            }
        }
        .overlay {
            if dogWalkEntries.isEmpty {
                if isInSearchMode {
                    ContentUnavailableView.search
                }
                else {
                    ContentUnavailableView {
                        Label("Start walkinging", systemImage: "figure.walk.circle.fill")
                    } description: {
                        Text("Keep track of your walk with your dog\nAdd a new entry to get started.")
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
            try? modelContext.save()
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
