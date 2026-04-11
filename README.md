# 💰 Finova — Personal Finance Companion

> A beautifully crafted mobile finance companion built with Flutter. Track transactions, monitor goals, visualize spending patterns, and build better money habits — all from one elegant app.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [App Screens & Features](#app-screens--features)
- [Architecture](#architecture)
- [State Management](#state-management)
- [Local Data Handling](#local-data-handling)
- [Enhancements](#enhancements)
- [Setup & Installation](#setup--installation)
- [Dependencies](#dependencies)

---

## 🌟 Overview

**Finova** is a personal finance companion focused on clarity, daily engagement, and actionable insight — intentionally not a banking app. Built with three core principles:

- **Product thinking first** — every screen solves a real user need
- **Consistency over complexity** — well-finished features beat bloated ones
- **Mobile-native design** — built for thumbs, not cursors

---

## 📸 Screenshots

| | | |
| :-: | :-: | :-: |
| <img src="https://github.com/user-attachments/assets/508cb06b-d238-40d7-a72b-959fc2a365ef" width="300"> | <img src="https://github.com/user-attachments/assets/2825cca9-3b1e-4caa-bb55-dd83f977f7b2" width="300"> | <img src="https://github.com/user-attachments/assets/10081473-9c41-4365-909f-834e008dd131" width="300"> |
| <img src="https://github.com/user-attachments/assets/8dee805a-72c4-4c28-b10b-1daab22761ba" width="300"> | <img src="https://github.com/user-attachments/assets/eec0080d-920f-49cf-81f3-b3f31f72767d" width="300"> | <img src="https://github.com/user-attachments/assets/3606e275-d7db-4813-809e-c1a6cc30e0a6" width="300"> |
| <img src="https://github.com/user-attachments/assets/67cb86dc-0980-4b69-8396-df066803f822" width="300"> | <img src="https://github.com/user-attachments/assets/156f318f-0fb5-426b-8381-b0c4ff28d421" width="300"> | <img src="https://github.com/user-attachments/assets/f0c671a6-9bcb-41ce-a264-8bd20f16f307" width="300"> |
| <img src="https://github.com/user-attachments/assets/226d832e-0c2d-4c3d-b8c8-7a97f7d468ea" width="300"> | <img src="https://github.com/user-attachments/assets/d7fd34c8-59e8-48c2-9352-10707d56d1e1" width="300"> | <img src="https://github.com/user-attachments/assets/90a8cece-986b-487b-980e-9375bf3df41e" width="300"> |
| <img src="https://github.com/user-attachments/assets/8a51d5e4-aa9f-4745-ba63-fb8c06d7cdd5" width="300"> | <img src="https://github.com/user-attachments/assets/5d360e95-3125-4dbc-9139-b062f9351332" width="300"> | <img src="https://github.com/user-attachments/assets/d6ed30aa-9d59-44e3-baf8-8d91b842ffa4" width="300"> |

---

## 📱 App Screens & Features

**🔐 Auth & Onboarding** — Clean login and sign-up backed by local SQLite with session persistence via SharedPreferences. New users go through a 3-step onboarding flow to set their name, starting balance, and monthly budget before hitting the dashboard.

**🏠 Home Dashboard** — An at-a-glance view of financial health: net worth, income/expense summary cards, a custom-painted donut chart for spending allocation, monthly budget tracker, active goal progress bar, and a scrollable recent activity feed.

**💳 Transactions** — Full CRUD via an intuitive bottom sheet. Supports category picker, date shortcuts (Today/Yesterday + calendar), search by category or notes, filter chips (All/Income/Expense), and a grouped list with human-friendly date headers.

**🎯 Goals & Challenges** — Set a monthly savings target with progress computed live from real transaction data. Paired with a no-spend challenge featuring a weekly day tracker, streak counter, and suggested challenge cards to keep users motivated.

**📊 Insights** — Surfaces spending patterns at a glance: biggest expense category, proportional spending heatmap for top 5 categories, weekly average spend, a contextual smart tip, and a live goal focus card.

**👤 Profile** — Edit name, budget, and profile photo. Includes a dark mode toggle (persisted), biometric lock (requires live auth before enabling), data export to `.xlsx`, and a full account delete option.

**🔔 Notifications** — Auto-generated alerts for every transaction, daily login security events, and a 10 PM daily reminder. Grouped into Today & Earlier, with unread indicators and read-marking support.

---

## 🏗️ Architecture

Clean layered architecture with clear separation of concerns:

```
lib/
├── core/              # Theme, colors, constants
├── data/              # SQLite datasource + repository implementations
├── domain/            # Entities, models, abstract repository interfaces
├── presentation/      # Screens, blocs, widgets per feature
└── services/          # BiometricService, NotificationService, ExportService
```

Domain-layer abstract interfaces (`IAuthRepository`, `TransactionRepository`, etc.) keep the presentation layer decoupled from concrete implementations. Cross-cutting side effects (e.g. creating a notification on transaction add) are handled at the repository layer, not in blocs.

---

## 🔄 State Management

**flutter_bloc** throughout, with a consistent event → state pattern. All blocs are provided globally via `MultiBlocProvider` in `main.dart`.

| Bloc | Responsibility |
|---|---|
| `AuthBloc` | Login, sign-up, session, onboarding, profile, account deletion |
| `TransactionBloc` | Add, fetch, update, delete transactions |
| `GoalBloc` | Fetch, add, update monthly goals |
| `ChallengeBloc` | No-spend challenge, streak calculation, week day status |
| `InsightsBloc` | Spending aggregation, category breakdowns, weekly average |
| `NotificationBloc` | Load notifications, mark as read |
| `ThemeCubit` | Toggle and persist light/dark mode |

---

## 🗄️ Local Data Handling

Fully **offline-first** — all data persisted locally via **SQLite (sqflite)**. No network dependency.

**Schema (v3):** `users` · `transactions` · `goals` · `challenges` · `notifications`

Migrations use `onUpgrade` with versioned steps (v1→v2 adds `profileImagePath`, v2→v3 adds `notifications`) — existing installs upgrade without data loss. Session is restored via the logged-in email stored in `SharedPreferences`.

---

## ✨ Enhancements

| Enhancement | Details |
|---|---|
| ✅ Dark Mode | Full theme system via `ThemeCubit`, persisted across sessions |
| ✅ Push Notifications | Daily 10 PM reminder via `flutter_local_notifications` with timezone scheduling |
| ✅ Animated Transitions | `flutter_animate` staggered list entries + `FadeSlideAnimation` screen transitions |
| ✅ Data Export | Full DB export to `.xlsx` via the `excel` package, shared via native share sheet |
| ✅ Biometric Lock | Fingerprint / Face ID via `local_auth`, requires live auth challenge before enabling |
| ✅ Profile Settings | Name, budget, and photo editable from a polished bottom sheet |

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK `^3.11.3`
- Android Studio / Xcode

```bash
git clone https://github.com/your-username/finova.git
cd finova
flutter pub get
flutter run
```

> 📌 Biometric auth requires a physical device — emulator falls back gracefully.  
> 📌 Android 13+ will prompt for notification permissions on first launch.

### Build
```bash
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS
```

---


## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` · `equatable` | State management + value equality |
| `sqflite` · `shared_preferences` | Local DB + lightweight key-value persistence |
| `google_fonts` · `intl` | Typography + currency/date formatting |
| `flutter_animate` | Declarative animations |
| `local_auth` | Biometric authentication |
| `flutter_local_notifications` · `timezone` | Scheduled push notifications |
| `image_picker` | Profile photo from gallery |
| `excel` · `share_plus` · `path_provider` · `path` | Data export to `.xlsx` + native sharing |

---

*Built with Flutter · Designed for everyday use · Fully offline-first* 🌿
