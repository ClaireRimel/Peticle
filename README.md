# Peticle 🐾

**Peticle** is an iOS demo app designed to showcase the full breadth of the **App Intents** framework. Inspired by my golden retriever Alfie, the app tracks dog walks while demonstrating 20+ intents, entities, Live Activities, widgets, Siri integration, Focus filters, Spotlight indexing, and more.

> Almost nothing to do inside the app… and that’s the point! 👏  

---

## App Intents Showcase

### Intents (21 total)

| Intent | Type | Description |
|--------|------|-------------|
| `StartDogWalkIntent` | `LiveActivityIntent` | Start a walk with a goal time, launches a Live Activity |
| `StopDogWalkIntent` | `LiveActivityIntent` | Stop the current walk, save progress |
| `AddWalkIntent` | `AppIntent` + `PredictableIntent` | Log a walk with duration and quality, with system prediction |
| `AddDogIntent` | `AppIntent` | Add a new dog to the collection |
| `RemoveDogIntent` | `AppIntent` | Remove a dog |
| `DeleteWalkIntent` | `AppIntent` | Delete a walk entry with confirmation dialog |
| `UpdateWalkQualityIntent` | `AppIntent` | Update quality with date selection and disambiguation |
| `EditDurationIntent` | `AppIntent` | Edit walk duration |
| `EditWalkQualityIntent` | `AppIntent` | Edit walk quality rating |
| `EditDurationThenQualityIntent` | `AppIntent` | Compound: edit both duration and quality |
| `WalksTodayCountIntent` | `AppIntent` | Returns today's walk count |
| `GetLastActivityIntent` | `AppIntent` | Returns the most recent walk entry |
| `AddWalkQualityLatestActivityIntent` | `AppIntent` | Quick quality update for latest walk |
| `WalkingRecommendationIntent` | `AppIntent` | Personalized walking recommendation |
| `SeeLatestActivityIntent` | `AppIntent` + `ShowsSnippetView` | Display last walk in a Snippet UI |
| `ManageLatestWalkEntryIntent` | `SnippetIntent` | Manage last walk in a Snippet view (iOS 26) |
| `ShowDogIntent` | `AppIntent` + `ShowsSnippetView` | Show dog info with photo in Snippet |
| `OpenEditEntryIntent` | `OpenIntent` + `URLRepresentableIntent` | Open app to edit a walk, supports deep links |
| `OpenSecretViewWalkIntent` | `AppIntent` | Hidden intent for a secret feature |
| `DogWalkingFocus` | `SetFocusFilterIntent` | Filter walks during a Focus mode |
| `CreateNewDogWalkIntent` | `AppIntent` + `DeprecatedAppIntent` | Deprecated, migrates to `AddWalkIntent` |

### Entities (2)

| Entity | Protocols | Properties |
|--------|-----------|------------|
| `DogEntity` | `IndexedEntity`, `EntityStringQuery` | name, age, imageData, addedDate |
| `DogWalkEntryEntity` | `IndexedEntity`, `URLRepresentableEntity` | date, durationInMinutes, walkQuality, `@ComputedProperty timeAgo` |

### Entity Queries

| Query | Protocols | Features |
|-------|-----------|----------|
| `DogQuery` | `EnumerableEntityQuery`, `EntityStringQuery` | Natural language search by name |
| `DogWalkQuery` | `EntityPropertyQuery` | Filterable by date, duration, quality. Sortable. Auto-generates "Find Dog Walks" in Shortcuts |

### App Enums

| Enum | Cases |
|------|-------|
| `WalkQuality` | `.ok`, `.bad`, `.good`, `.wonderful` (with emoji images) |
| `DateSelection` | `.today`, `.yesterday` |

---

## Live Activity & Dynamic Island

A full **ActivityKit** integration with 4 presentation modes:

- **Lock Screen**: Horizontal layout with timer, progress bar, and goal
- **Expanded Dynamic Island**: Icon + label, timer + goal, progress bar
- **Compact**: Dog icon (leading) + circular progress with timer (trailing)
- **Minimal**: Circular progress with dog icon

Managed by `StopwatchViewModel` with:
- State persistence across app restarts (UserDefaults)
- Halfway and goal completion notifications
- Orphaned activity cleanup
- Live Activity reconnection on relaunch

---

## Widgets (3)

| Widget | Type | Description |
|--------|------|-------------|
| `PeticleWidgetLiveActivity` | Live Activity | Timer and progress in Dynamic Island and Lock Screen |
| `PeticleQuickActionsWidget` | Interactive (`systemSmall`) | Today's walk count + Start/Stop button via App Intents |
| `OpenSecretViewControl` | `ControlWidget` | Control Center button for a hidden feature |

The interactive widget uses **App Group** shared `UserDefaults` (`group.com.Yo.Peticle`) to sync the walking state between the app and widget extension.

---

## Siri & Shortcuts

### AppShortcutsProvider

8 registered App Shortcuts with localized phrases covering:
- Start/Stop walks
- Add and manage walk entries
- Update walk quality
- View latest activity
- Show dog information

### Negative Phrases

Trained Siri to **not** activate for similar-sounding phrases like *"Walk me through"* or *"Walking directions"*.

### SiriTipViews (3)

Contextual Siri tips displayed in `AddDogView`, `DogWalkListView`, and `DogWalkEntryView`.

---

## Advanced Features

| Feature | Implementation |
|---------|---------------|
| **PredictableIntent** | `AddWalkIntent` with 3-level prediction configuration. System learns usage patterns |
| **Intent Donation** | Walk intents are donated after creation for Spotlight suggestions |
| **SetFocusFilterIntent** | `DogWalkingFocus` filters the walk list to today-only during a Focus mode |
| **EntityPropertyQuery** | `DogWalkQuery` with comparators and sorting, auto-generates Shortcuts filters |
| **EntityStringQuery** | `DogQuery` with natural language name search |
| **URLRepresentableEntity** | Deep link support for `DogWalkEntryEntity` |
| **URLRepresentableIntent** | `OpenEditEntryIntent` supports URL-based invocation |
| **DeprecatedAppIntent** | `CreateNewDogWalkIntent` with migration to `AddWalkIntent` |
| **@ComputedProperty** | `timeAgo` on `DogWalkEntryEntity` for relative date display |
| **NegativeAppShortcutPhrases** | Prevents false Siri triggers |
| **SnippetIntent** | `ManageLatestWalkEntryIntent` with custom SwiftUI snippet view (iOS 26) |
| **Spotlight Indexing** | Both entities indexed via `CSSearchableIndex` with rich attributes |

---

## Architecture

- **SwiftData** for persistence (`Dog`, `DogWalkEntry` models with `Sendable`)
- **@Observable** view models (`StopwatchViewModel`, `NavigationManager`)
- **AppDependencyManager** for type-safe dependency injection across intents
- **App Group** (`group.com.Yo.Peticle`) for app-widget communication

---

## Requirements

- iOS 26+
- Swift 5.9+
- Xcode 26+
