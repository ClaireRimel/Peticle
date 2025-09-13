# Peticle 🐾

**Peticle** is a lightweight iOS app designed to help you track your puppy’s walks in a **simple, fun, and interactive way**. Inspired by my golden retriever Alfie, the app leverages **App Intents** to let Siri and Shortcuts handle most of the interactions, so you can focus on your furry friend!  

> Almost nothing to do inside the app… and that’s the point! 👏  

---

## Features

- Track walks with start/stop functionality  
- Receive Siri suggestions to start or stop a walk  
- Set walk goals (duration in minutes) via Siri  
- Rate interactions during walks with your puppy using a fun emoji system:  
  - 🌙 → no interaction  
  - ☀️ → okay  
  - 🌈 → super fun  
  - ⛈ → not cool  
- Update walk duration, human interaction, and dog interaction via App Intents  
- Open specific app screens directly from Shortcuts  
- Integrates with **Widgets** for quick access  
- Hidden intents for special features  

---

## How It Works

Peticle relies heavily on **App Intents**:

- **Start/Stop Walk** intents:  
  - Start walk → minimal interaction, live activity updates  
  - Stop walk → dialog confirms walk is registered  

- **LatestActivityIntent**:  
  - Displays the last walk entry with interaction summary  
  - Returns data that can be updated by the user (duration, interactions)  

- **OpenEditEntryIntent**:  
  - Opens the app to edit a specific walk entry, making it user-friendly  

- **AppShortcutsProvider**:  
  - Register intents to be available in Shortcuts  
  - Use `updateAppShortcutParameters()` to dynamically update parameters  
  - Localized phrases and custom icons for better UX  

- **Widgets & Hidden Intents**:  
  - Make App Intents discoverable or hidden  
  - Example: `OpenSecretViewWalkIntent` for special features  

---

## Why App Intents Are Powerful

- Engage users with context-aware actions via Siri and Shortcuts  
- Automate repetitive tasks and create custom shortcuts  
- Integrate with widgets for even more accessibility  
- Expand functionality every year with new iOS features like `SnippetIntent`  

---

## Requirements

- iOS 26+
- Swift 5.9+  
- Xcode 26+  

---
