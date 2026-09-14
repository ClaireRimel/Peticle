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
    @State private var showingAddDog = false

    var body: some View {
        @Bindable var navigation = navigation
        NavigationStack(path: $navigation.dogWalkNavigationPath) {
            FilteredDogWalkListView(searchTerm: navigation.searchText)
            .navigationTitle("Alfie\'s Chronicle")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Add a walk", systemImage: "figure.walk") {
                            navigation.composeNewDogWalkEntry()
                        }
                        Button("Add a dog", systemImage: "pawprint.fill") {
                            showingAddDog = true
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                }
            }
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

            .sheet(isPresented: $showingAddDog) {
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
    private var isInSearchMode = false

    /// Same model the Start / Stop intents drive, so a walk started from
    /// Siri appears here without any glue code.
    private let stopwatch = StopwatchViewModel.shared

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

    private var todaysEntries: [DogWalkEntry] {
        dogWalkEntries.filter { Calendar.current.isDateInToday($0.entryDate) }
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
        ScrollView {
            VStack(spacing: PeticleTheme.Spacing.lg) {
                // Focus filter active banner
                if showOnlyTodaysWalks {
                    GlassPill("Focus filter active — showing today only", systemImage: "moon.fill", tint: .indigo.opacity(0.3))
                }

                if !isInSearchMode {
                    header
                    todayMetrics
                }

                if displayedEntries.isEmpty {
                    emptyState
                } else {
                    walkHistory
                }
            }
            .padding(.horizontal, PeticleTheme.Spacing.lg)
            .padding(.top, PeticleTheme.Spacing.sm)
            .padding(.bottom, PeticleTheme.Spacing.xl)
        }
        .onAppear() {
            modelContext.rollback()
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var header: some View {
        if stopwatch.isRunning {
            ActiveWalkCard(stopwatch: stopwatch, onStop: stopWalk)
        } else {
            if !dogs.isEmpty {
                GreetingHero(dogs: dogs, walksTodayCount: todaysEntries.count)
            }
            GlassPrimaryButton("Start a walk", systemImage: "play.fill") {
                stopwatch.start(with: StopwatchViewModel.defaultGoalInMinutes)
            }
        }
    }

    private var todayMetrics: some View {
        let totalMinutes = todaysEntries.reduce(0) { $0 + $1.durationInMinutes }

        return HStack(spacing: PeticleTheme.Spacing.md) {
            GlassMetricTile(value: "\(todaysEntries.count)", label: "Walks today", systemImage: "figure.walk")
            GlassMetricTile(
                value: "\(totalMinutes)'",
                label: "Total time",
                caption: "Goal: \(StopwatchViewModel.defaultGoalInMinutes)'",
                systemImage: "clock.fill"
            )
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
