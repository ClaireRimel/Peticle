//
//  DogWalkListView.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import SwiftUI
import WidgetKit
import SwiftData
import CoreSpotlight
import Collections
import AppIntents

struct DogWalkListView: View {
    @Environment(NavigationManager.self) private var navigation
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
    @Environment(NavigationManager.self) private var navigation
    @Query(sort: \DogWalkEntry.entryDate, order: .reverse)
    private var dogWalkEntries: [DogWalkEntry]
    @Query(sort: \Dog.addedDate) private var dogs: [Dog]
    private let searchTerm: String
    private var isInSearchMode: Bool { !searchTerm.isEmpty }

    /// Same model the Start / Stop intents drive, so a walk started from
    /// Siri appears here without any glue code.
    private let stopwatch = StopwatchViewModel.shared

    /// A binding to a user preference indicating whether they hide the Siri tip.
    @AppStorage("displaySiriTip") private var displaySiriTip: Bool = true

    /// Read the Focus filter state set by DogWalkingFocus (SetFocusFilterIntent).
    /// When a Focus mode activates with this filter, only today\'s walks are shown.
    @AppStorage("focusFilter_showOnlyTodaysWalks") private var showOnlyTodaysWalks: Bool = false

    @Environment(\.dismissSearch) private var dismissSearch
    @State private var entryToRedate: DogWalkEntry?

    /// The entries to display, filtered by Focus mode and by the search term.
    private var displayedEntries: [DogWalkEntry] {
        let calendar = Calendar.current
        return dogWalkEntries.filter { entry in
            (!showOnlyTodaysWalks || calendar.isDateInToday(entry.entryDate))
                && (!isInSearchMode || matchesSearch(entry))
        }
    }

    /// Words that describe every walk: Siri often sends whole requests
    /// like "walks registered", which should list everything.
    private static let genericSearchWords: Set<String> = [
        "walk", "walks", "dog", "dogs", "my", "all", "registered", "logged",
        "promenade", "promenades", "balade", "balades", "mes", "toutes"
    ]

    /// Filtered in memory: SwiftData predicates can't read `Date.description`
    /// (it crashes at runtime), and people search with readable dates anyway.
    /// Every meaningful word must match something about the walk.
    private func matchesSearch(_ entry: DogWalkEntry) -> Bool {
        let calendar = Calendar.current
        var candidates = [
            entry.entryDate.formatted(date: .complete, time: .shortened),
            entry.entryDate.formatted(date: .numeric, time: .omitted),
            "\(entry.durationInMinutes) min",
            entry.walkQuality.rawValue
        ]
        if calendar.isDateInToday(entry.entryDate) { candidates += ["today", "aujourd'hui"] }
        if calendar.isDateInYesterday(entry.entryDate) { candidates += ["yesterday", "hier"] }

        return searchWords.allSatisfy { word in
            candidates.contains { $0.localizedStandardContains(word) }
        }
    }

    /// The search term's meaningful words, without generic ones like "walks".
    private var searchWords: [String] {
        searchTerm
            .lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "/" && $0 != "'" })
            .map(String.init)
            .filter { !Self.genericSearchWords.contains($0) }
    }

    /// Animals named in the search ("Search for Alfie") or of a species
    /// ("Search for cats"): the in-app search covers all of Peticle's
    /// content, not only walks.
    private var matchingDogs: [Dog] {
        guard isInSearchMode, !searchWords.isEmpty else { return [] }
        return dogs.filter { dog in
            searchWords.contains { word in
                dog.name.localizedStandardContains(word)
                    || (dog.species.map { word.localizedStandardContains($0.name) } ?? false)
            }
        }
    }

    private var todaysEntries: [DogWalkEntry] {
        dogWalkEntries.filter { Calendar.current.isDateInToday($0.entryDate) }
    }

    init(searchTerm: String) {
        self.searchTerm = searchTerm
    }

    static let todayString = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: Date.now)
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: PeticleTheme.Spacing.lg) {
                // Focus filter active banner
                if showOnlyTodaysWalks {
                    GlassPill("Focus filter active — showing today only", systemImage: "moon.fill", tint: .indigo.opacity(0.3))
                }

                // No search bar: searches only come from Siri (.system.searchInApp).
                // This pill shows the term and clears it, so the list never
                // stays stuck on the results.
                if isInSearchMode {
                    Button {
                        withAnimation { navigation.searchText = "" }
                    } label: {
                        GlassPill("Results for “\(searchTerm)”", systemImage: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Clears the search")
                }

                if !isInSearchMode {
                    header
                }

                if !matchingDogs.isEmpty {
                    dogResults
                }

                if !displayedEntries.isEmpty {
                    walkHistory
                } else if matchingDogs.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, PeticleTheme.Spacing.lg)
            .padding(.top, PeticleTheme.Spacing.sm)
            .padding(.bottom, PeticleTheme.Spacing.xl)
        }
        // iOS 27: lets the rows' swipe actions work outside a List.
        .swipeActionsContainer()
        .sheet(item: $entryToRedate) { entry in
            EditWalkDateSheet(entry: entry)
        }
        .onAppear() {
            modelContext.rollback()
        }
    }

    // MARK: - Sub-views

    private var dogResults: some View {
        VStack(alignment: .leading, spacing: PeticleTheme.Spacing.sm) {
            Text("Dogs")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, PeticleTheme.Spacing.md)

            ForEach(matchingDogs) { dog in
                GlassCard(padding: PeticleTheme.Spacing.lg) {
                    HStack(spacing: PeticleTheme.Spacing.md) {
                        DogAvatarView(dog: dog, diameter: 48)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dog.name)
                                .font(.body.weight(.semibold))
                            if let species = dog.species {
                                Label(species.name, systemImage: species.symbolName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text("\(dog.age) years old")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        if stopwatch.isRunning {
            ActiveWalkCard(stopwatch: stopwatch, onStop: stopWalk)
        } else if !dogs.isEmpty {
            // No Start button: walks start from Siri, Shortcuts or the widget.
            GreetingHero(dogs: dogs, walksTodayCount: todaysEntries.count)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if isInSearchMode {
            GlassEmptyState(
                title: "No results",
                message: "Try another date.",
                systemImage: "magnifyingglass"
            )
        } else {
            GlassEmptyState(
                title: "Start walking",
                message: "Keep track of your walks with your dog \nAdd a new entry to get started",
                systemImage: "figure.walk.circle.fill"
            ) {
                /**
                 `SiriTipView` pairs with an intent the system uses as an App Shortcut. It provides a small view with the phrase from the
                 App Shortcut so that people learn they can view their favorite trails quickly by speaking the phrase to Siri with no
                 additional setup. The `isVisible` parameter is optional, but recommended to enable people to hide the view.
                 */
                #if os(iOS)
                SiriTipView(intent: StartDogWalkIntent(), isVisible: $displaySiriTip)
                #endif
            }
        }
    }

    private var walkHistory: some View {
        let calendar = Calendar.current
        let groupedEntries = OrderedDictionary(grouping: displayedEntries, by: { entry in
            if calendar.isDateInToday(entry.entryDate) { return Self.todayString }
            else { return calendar.startOfDay(for: entry.entryDate).formatted(.relative(presentation: .named)) as String }
        })

        return ForEach(Array(groupedEntries.keys), id: \.self) { group in
            VStack(alignment: .leading, spacing: PeticleTheme.Spacing.sm) {
                Text(group)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, PeticleTheme.Spacing.md)

                ForEach(groupedEntries[group] ?? []) { entry in
                    Button {
                        navigation.modifyEntry = entry
                    } label: {
                        DogWalkEntryCellView(dogWalkEntry: entry)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Edit date", systemImage: "calendar") {
                            entryToRedate = entry
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deleteEntries(entries: [entry])
                        }
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deleteEntries(entries: [entry])
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    /// Stops the walk, then opens the new entry so the walk can be rated
    /// while it's fresh — like Habanera's rating sheet.
    private func stopWalk() {
        Task {
            let previousLastID = try? await DataModelHelper.lastDogEntry()?.dogWalkID
            try? stopwatch.saveEntryAndStopActivity()
            if let lastEntry = try? await DataModelHelper.lastDogEntry(),
               lastEntry.dogWalkID != previousLastID {
                navigation.modifyEntry = lastEntry
            }
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

        WidgetCenter.shared.reloadTimelines(ofKind: "com.Yo.Peticle.QuickActions")

        if let count = try? modelContext.fetchCount(FetchDescriptor<DogWalkEntry>()),
           count == 0 {
            dismissSearch()
        }
    }
}
