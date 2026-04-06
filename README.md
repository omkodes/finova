# Finova — Personal Finance Companion

> A beautifully crafted mobile finance companion built with Flutter. Track transactions, monitor goals, visualize spending patterns, and build better money habits — all from one elegant app.

---

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [App Screens & Features](#app-screens--features)
- [Architecture & Technical Decisions](#architecture--technical-decisions)
- [State Management](#state-management)
- [Local Data Handling](#local-data-handling)
- [Optional Enhancements Implemented](#optional-enhancements-implemented)
- [Setup & Installation](#setup--installation)
- [Project Structure](#project-structure)
- [Design Decisions & Assumptions](#design-decisions--assumptions)
- [Dependencies](#dependencies)

---

## Overview

**Finova** is a personal finance companion app that helps users develop mindful money habits. It is intentionally not a banking app — instead, it focuses on clarity, daily engagement, and actionable insight, designed to feel personal and polished from the very first launch.

The app was built with the following principles in mind:

- **Product thinking first** — every screen exists to solve a real user need, not just to meet a checklist.
- **Consistency over complexity** — a well-finished set of features beats a bloated one.
- **Mobile-native design** — interactions, navigation, and layouts are designed for thumbs, not cursors.

---
<!--
## Screenshots

> Screenshots captured on a Pixel 8 emulator running Android 14. Both light and dark themes are shown.

### Onboarding & Authentication

| Login | Sign Up | Onboarding |
|:---:|:---:|:---:|
| ![Login Screen](screenshots/login.png) | ![Sign Up Screen](screenshots/signup.png) | ![Onboarding](screenshots/onboarding.png) |

### Home Dashboard

| Dashboard (Light) | Dashboard (Dark) | Spending Chart |
|:---:|:---:|:---:|
| ![Dashboard Light](screenshots/dashboard_light.png) | ![Dashboard Dark](screenshots/dashboard_dark.png) | ![Spending Chart](screenshots/spending_chart.png) |

### Transaction Management

| Transaction List | Add Transaction | Transaction Details |
|:---:|:---:|:---:|
| ![Transactions](screenshots/transactions.png) | ![Add Transaction](screenshots/add_transaction.png) | ![Transaction Details](screenshots/transaction_details.png) |

### Goals & Challenges

| Goals Screen | No Spend Challenge | Goal Progress |
|:---:|:---:|:---:|
| ![Goals](screenshots/goals.png) | ![Challenge](screenshots/challenge.png) | ![Goal Progress](screenshots/goal_progress.png) |

### Insights

| Insights Overview | Spending Heatmap | Smart Tips |
|:---:|:---:|:---:|
| ![Insights](screenshots/insights.png) | ![Heatmap](screenshots/heatmap.png) | ![Smart Tips](screenshots/smart_tips.png) |

### Profile & Settings

| Profile | Edit Profile | Biometric Lock |
|:---:|:---:|:---:|
| ![Profile](screenshots/profile.png) | ![Edit Profile](screenshots/edit_profile.png) | ![Biometric](screenshots/biometric.png) |

### Notifications

| Notifications | Dark Mode |
|:---:|:---:|
| ![Notifications](screenshots/notifications.png) | ![Dark Mode](screenshots/dark_mode.png) |

> **To add your screenshots:** Create a `screenshots/` folder at the root of the repository and save each image with the filename shown above. Recommended size: **390 × 844 px** (iPhone 14 ratio) or use a device frame tool like [Previewed](https://previewed.app) or [Mockup Phone](https://mockuphone.com) to add a polished phone frame around each capture.

---

-->

## App Screens & Features

### 1. Authentication & Onboarding

A clean, animated login and sign-up flow backed by a local SQLite database. New users are taken through a **3-step onboarding experience** to configure their name, starting balance, and monthly budget before reaching the dashboard.

- Email + password authentication (stored locally via SQLite)
- Session persistence using `SharedPreferences`
- Smooth fade-slide page transitions between screens
- Onboarding skippable with sensible defaults (0.0 balance and budget)

### 2. Home Dashboard

The home screen gives users an at-a-glance picture of their financial health without feeling cluttered.

- **Net worth** calculated as total income minus total expenses
- **Income and expense summary cards** with colored indicators
- **Spending Allocation donut chart** — custom-painted `CustomPainter` implementation showing up to 4 spending categories with a legend
- **Monthly budget tracker** — displays how much of the user's set budget has been spent
- **Active goal progress card** — shows the current savings goal with a live progress bar and percentage
- **Recent Activity feed** — a horizontal scrollable list of the 5 most recent transactions

### 3. Transaction Tracking

Full CRUD support for financial entries via an intuitive bottom sheet flow.

- Add income or expense with a single tap from any screen via the floating action button
- Fields: amount, type (income/expense), category (Groceries, Rent, Salary, Transport, Dining), date, and optional notes
- **Category picker** with icon tiles for quick visual selection
- **Date picker** with Today / Yesterday shortcuts and a full calendar fallback
- **Search bar** to query transactions by category or notes
- **Filter chips** for All / Income / Expense and a dropdown category filter
- **Grouped list** — transactions are grouped by date with human-friendly headers (Today, Yesterday, or full date)
- **Transaction details bottom sheet** — tap any transaction to view full details, edit, or delete
- All changes immediately propagate to the Insights and Goals blocs via events

### 4. Goals & Challenges Screen

This screen combines a monthly savings goal with a gamified no-spend challenge — the two features work together to create an engaging, habit-building experience.

**Monthly Goal**
- Set a target savings amount for the current month
- Progress is computed dynamically from real income/expense data (not manually entered)
- Progress bar with gradient fill, percentage label, and motivational copy
- "Goal Reached" state with a green completion indicator
- Edit goal inline without leaving the screen

**No Spend Challenge**
- Start / stop a no-spend streak at any time
- Weekly day tracker (Mon–Sun) marks each past day green if no expenses were logged that day, with a pulsing border on today
- Streak counter calculated by walking backwards from today through expense history
- Future days are shown greyed out to avoid confusion

**Suggested Challenges**
- Two static but contextually relevant challenge cards (Coffee Free Month, Walk to Work) to inspire users

### 5. Insights Screen

A dedicated screen for understanding spending patterns at a glance.

- **Biggest Expense card** — highlights the category with the highest spend this month with the exact amount
- **Spending Heatmap** — a vertical bar chart of the top 5 spending categories, sized proportionally to the biggest category
- **Weekly Average card** — computed as `(totalSpent / daysInMonth) × 7` for accuracy
- **Smart Tip card** — a contextual suggestion based on the user's biggest category (e.g. "Consider setting a budget limit for Dining")
- **Goal Focus card** — shows real-time savings progress against the active goal, pulling live data from the transaction and goal blocs

### 6. Profile Screen

A settings and identity hub.

- Avatar display with tap-to-edit profile picture (image picker from gallery)
- Edit name, monthly budget, and profile photo via a bottom sheet
- **Dark mode toggle** — persisted across app sessions using `SharedPreferences`
- Currency and language settings display (INR / English)
- **Biometric login toggle** — requires a live authentication challenge before enabling
- Logout with full session cleanup
- **Delete Account** — permanently removes all user data (users, transactions, goals, challenges, notifications) from the local database

### 7. Notifications

An in-app notification feed categorized by type.

- **Transaction alerts** — auto-created each time a transaction is added
- **Security alerts** — logged once per day on login
- **Daily reminder** — added at 10 PM if not already present for the day
- **System notifications** — welcome message on sign-up
- Grouped into "Today" and "Earlier" sections
- Unread indicator dot on each unread notification
- Read marking via bloc events

---

## Architecture & Technical Decisions

The app follows a **layered clean architecture** with clear separation of concerns:

```
lib/
├── core/              # Theme, colors, app-wide constants
├── data/
│   ├── datasources/   # SQLite database service
│   └── repositories/  # Concrete repository implementations
├── domain/
│   ├── entities/      # Pure data models (TransactionEntity, GoalEntity, etc.)
│   ├── models/        # Non-entity models (AppNotification)
│   └── repositories/  # Abstract repository interfaces
├── presentation/
│   ├── auth/          # Login, sign-up, biometric wrapper, AuthBloc
│   ├── home/          # Dashboard, TransactionBloc
│   ├── transactions/  # Transaction list screen, details bottom sheet
│   ├── goals/         # Goals screen, GoalBloc, ChallengeBloc
│   ├── insights/      # Insights screen, InsightsBloc
│   ├── notifications/ # Notifications screen, NotificationBloc
│   ├── profile/       # Profile screen, edit profile bottom sheet
│   ├── theme/         # ThemeCubit
│   └── widgets/       # Shared UI widgets (FadeSlideAnimation, etc.)
└── services/          # BiometricService, NotificationService, ExportService
```

**Key decisions:**

- **Domain layer uses abstract interfaces** (`IAuthRepository`, `TransactionRepository`, `GoalRepository`, `ChallengeRepository`) so the presentation layer never depends on concrete implementations. This makes the codebase testable and swappable.
- **Equatable** is used on all entities and bloc states to ensure efficient equality checks and prevent unnecessary rebuilds.
- **Bloc events are re-dispatched** after mutations (e.g. after adding a transaction, a `TransactionFetchRequested` event is added) to keep the UI in sync without manual state stitching.
- **Cross-cutting side effects** (like creating a notification on transaction add) are handled at the repository layer, not the presentation layer, keeping blocs focused on UI concerns.

---

## State Management

**flutter_bloc** is used throughout the app with a consistent event → state pattern.

| Bloc | Responsibility |
|---|---|
| `AuthBloc` | Login, sign-up, session check, onboarding, profile update, account deletion |
| `TransactionBloc` | Add, fetch, update, delete transactions |
| `GoalBloc` | Fetch, add, update monthly goals |
| `ChallengeBloc` | Start, stop, fetch no-spend challenge; compute streak and week day status |
| `InsightsBloc` | Aggregate spending totals, category breakdowns, weekly average |
| `NotificationBloc` | Load notifications, mark as read |
| `ThemeCubit` | Toggle and persist light/dark mode |

All blocs are provided globally at the root via `MultiBlocProvider` in `main.dart`, ensuring they remain alive across navigation and screen switches.

---

## Local Data Handling

All data is persisted locally using **SQLite via sqflite**. There is no network dependency — the app is fully offline-first.

**Database schema (v3):**

- `users` — email, hashed-equivalent password, name, startingBalance, monthlyBudget, onboarding status, profile image path
- `transactions` — amount, type (0=expense, 1=income), category, date, notes, createdAt
- `goals` — title, targetAmount, currentSaved, month, year, createdAt
- `challenges` — type, limitAmount, startDate, streakCount, isActive
- `notifications` — title, description, type, isUnread, createdAt

**Migration strategy:** The database uses `onUpgrade` with versioned migrations (v1→v2 adds `profileImagePath`, v2→v3 adds the `notifications` table), ensuring existing installs upgrade gracefully without data loss.

**Session management:** The currently logged-in user's email is stored in `SharedPreferences` and looked up against the database on app start to restore the session.

---

## Optional Enhancements Implemented

| Enhancement | Implementation |
|---|---|
| ✅ Dark Mode | Full light/dark theme system with `ThemeCubit`, persisted across sessions |
| ✅ Push Notifications | Daily 10 PM reminder via `flutter_local_notifications` with timezone scheduling |
| ✅ Animated Transitions | `flutter_animate` for staggered list entry animations and `FadeSlideAnimation` widget for screen-level transitions |
| ✅ Data Export | Full database export to `.xlsx` (Excel) via the `excel` package, shared via the native share sheet |
| ✅ Profile Settings | Name, budget, and profile image editable from a polished bottom sheet |
| ✅ Biometric Lock | Fingerprint / Face ID app lock using `local_auth`, toggled from Profile with a live authentication challenge before enabling |
| ✅ Offline-First | 100% local data — app works without any network connection |

---

## Setup & Installation

### Prerequisites

- Flutter SDK `^3.11.3`
- Dart SDK (included with Flutter)
- Android Studio / Xcode for device or emulator

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-username/finova.git
cd finova

# 2. Install dependencies
flutter pub get

# 3. Generate launcher icons (optional, assets already bundled)
dart run flutter_launcher_icons

# 4. Run the app
flutter run
```

> **Note:** Biometric authentication requires a physical device. The emulator will fall back gracefully and skip the lock screen.

> **Note:** Push notification scheduling uses the device timezone. On first launch, the app requests notification permissions on Android 13+.

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Project Structure

```
finova/
├── android/                  # Android native project
├── ios/                      # iOS native project
├── assets/
│   └── images/               # App logo and launcher icon assets
├── lib/
│   ├── core/
│   │   └── theme/            # AppColors, AppTheme
│   ├── data/
│   │   ├── datasources/      # SqfliteDatabaseService
│   │   └── repositories/     # Auth, Transaction, Goal, Challenge, Notification impls
│   ├── domain/
│   │   ├── entities/         # UserAccount, TransactionEntity, GoalEntity, ChallengeEntity
│   │   ├── models/           # AppNotification
│   │   └── repositories/     # Abstract interfaces
│   ├── presentation/
│   │   ├── auth/             # Login, SignUp, BiometricWrapper, AuthBloc
│   │   ├── goals/            # GoalsScreen, GoalBloc, ChallengeBloc
│   │   ├── home/             # HomeScreen (dashboard), TransactionBloc
│   │   ├── insights/         # InsightsScreen, InsightsBloc
│   │   ├── notifications/    # NotificationsScreen, NotificationBloc
│   │   ├── onboarding/       # OnboardingScreen (3-step flow)
│   │   ├── profile/          # ProfileScreen, EditProfileBottomSheet
│   │   ├── theme/            # ThemeCubit
│   │   ├── transactions/     # TransactionsScreen, TransactionDetailsBottomSheet
│   │   └── widgets/          # FadeSlideAnimation, AddTransactionBottomSheet
│   ├── services/             # BiometricService, NotificationService, ExportService
│   └── main.dart             # App entry point, DI setup, AuthGate
├── pubspec.yaml
└── README.md
```

---

## Design Decisions & Assumptions

**Goal progress is computed dynamically.** Rather than requiring users to manually update "current saved" on a goal, the app derives progress from real transaction data (total income minus total expenses). This makes the feature feel live and automatic rather than a separate manual input.

**Transactions are not scoped by user in the database.** Since the app targets a single-device personal use case, all transactions belong to the one active session. Multi-user isolation would require foreign keys added to transaction, goal, and challenge tables — a straightforward migration if needed.

**Categories are a fixed list.** Groceries, Rent, Salary, Transport, and Dining cover the most common everyday finance categories. A future version could allow user-defined categories.

**Currency is fixed to INR (₹).** The assignment is designed for an Indian user context. The `intl` package's `NumberFormat.simpleCurrency(name: 'INR')` is used consistently throughout. Multi-currency support would add a conversion layer on top.

**Passwords are stored as plain text in SQLite.** This is intentional for the scope of a local-only demo app. In production, bcrypt or Argon2 hashing would replace this.

**No-spend challenge streak is calculated against all expense history**, not just days since the challenge started, giving users credit for streaks that predate the challenge start.

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `equatable` | Value equality for entities and states |
| `sqflite` | Local SQLite database |
| `shared_preferences` | Lightweight key-value persistence (session, theme, biometric setting) |
| `google_fonts` | Manrope and Inter typefaces |
| `intl` | Currency and date formatting |
| `flutter_animate` | Declarative animations and staggered list entry effects |
| `local_auth` | Biometric (fingerprint / Face ID) authentication |
| `flutter_local_notifications` | Scheduled and immediate push notifications |
| `timezone` | Timezone-aware notification scheduling |
| `image_picker` | Profile photo selection from device gallery |
| `excel` | Excel (.xlsx) data export |
| `share_plus` | Native share sheet for exported files |
| `path_provider` | Temporary file directory for export |
| `path` | File path utilities |

---

*Built with Flutter · Designed for everyday use · Fully offline-first*
