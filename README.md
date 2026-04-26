# Folio

Personal expense tracker built with Flutter. Track recurring and one-off expenses on a calendar, get reminders before they're due, and export everything to CSV.

## Features

- **Calendar view** — browse and add expenses by day; swipe between months
- **Recurring expenses** — daily, weekly, bi-weekly, monthly, quarterly, semi-annual, annual; edit end date or cancel series from any date
- **Reminders** — per-expense local notifications at 9 am (same day, 1 day, 2 days, or 1 week before due); auto-cancelled when paid or skipped
- **Categories** — built-in set plus custom categories with emoji and colour
- **Summary tab** — monthly total, progress bar, category breakdown, upcoming unpaid list
- **Settings** — currency, default recurrence frequency, week start day (Mon/Sun), light/dark/system theme; all persist across restarts
- **CSV export** — share all occurrences (name, category, amount, due date, status, paid date) via the system share sheet

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.41+ (stable) |
| Dart | 3.11+ |
| Xcode | 15+ (iOS builds) |
| Android Studio / SDK | API 21+ target |

Install Flutter: https://docs.flutter.dev/get-started/install

## Getting Started

```bash
git clone https://github.com/mohokh67/folio.git
cd folio
flutter pub get
flutter run
```

Pick a target with `-d`:

```bash
flutter run -d ios
flutter run -d android
flutter run -d macos
```

## Platform Setup — Notifications

Notifications require a small amount of platform configuration that is already committed to this repo, but documented here for reference.

### Android

`android/app/src/main/AndroidManifest.xml` includes:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

No additional steps needed.

### iOS

The app requests notification permission at runtime (when a reminder is first set). No manual `Info.plist` changes are required — `flutter_local_notifications` handles the permission dialog automatically.

## Running Tests

```bash
flutter test
```

Tests cover the recurrence engine, occurrence generator (real in-memory SQLite), and settings repository.

## Code Generation

This project uses Drift (database) and Riverpod code generation. After changing any Drift table definition or `@riverpod`-annotated provider, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Tech Stack

| | Package |
|---|---|
| State management | flutter_riverpod + riverpod_annotation |
| Database | drift + drift_flutter (SQLite) |
| Navigation | go_router |
| Notifications | flutter_local_notifications + timezone |
| File sharing | share_plus + path_provider |

## Project Structure

```
lib/
  main.dart                  # entry — initialises timezone + notifications
  app.dart                   # MaterialApp.router + theme wiring
  core/
    providers/               # Riverpod providers
    recurrence/              # frequency enum + recurrence engine
    router/                  # go_router + onboarding guard
    services/                # occurrence generator, notifications, CSV export
    settings/                # SettingsRepository (ChangeNotifier)
    theme/                   # light + dark ThemeData
  data/
    tables/                  # Drift table definitions
    database/                # AppDatabase, DAOs, migrations
  features/
    calendar/                # calendar screen + add-expense form + day sheet
    onboarding/              # first-run currency + frequency setup
    settings/                # settings screen + category management
    summary/                 # monthly summary screen
  shared/widgets/
    scaffold_with_nav.dart   # bottom nav shell
```
