# Settings, Notifications, CSV Export Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement issues #11 (Settings tab), #12 (Notifications), #13 (CSV export) on one branch.

**Architecture:** Extend SettingsRepository with theme/weekStartDay; add NotificationService (flutter_local_notifications + timezone); add CsvExportService (share_plus + path_provider); add reminderDays to Expenses table with DB migration v5.

**Tech Stack:** Flutter/Riverpod/Drift, flutter_local_notifications ^18, share_plus ^10, path_provider ^2, timezone (transitive dep)

---

### Task 1: Branch setup

- [ ] `git checkout main && git pull`
- [ ] `git checkout -b feat/11-12-13-settings-notifications-export`

---

### Task 2: SettingsRepository — add weekStartDay + themeMode (#11)

**Modify:** `lib/core/settings/settings_repository.dart`

- [ ] Add fields + getters for `weekStartDay` (bool, true=Sunday) and `themeMode` (ThemeMode)
- [ ] Load from DB in `load()`
- [ ] Add setters `setCurrency`, `setDefaultFrequency`, `setWeekStartDay`, `setThemeMode`

---

### Task 3: Wire themeMode in app.dart (#11)

**Modify:** `lib/app.dart`

- [ ] Watch settingsRepositoryProvider and use its themeMode for MaterialApp.router themeMode param

---

### Task 4: CalendarGrid — weekStartDay (#11)

**Modify:** `lib/features/calendar/widgets/calendar_grid.dart`

- [ ] Add `startOnSunday` bool param
- [ ] When true: weekdays = ['Sun'...'Sat'], leadingEmpties = firstDay.weekday % 7
- [ ] When false (current): weekdays = ['Mon'...'Sun'], leadingEmpties = firstDay.weekday - 1

---

### Task 5: CalendarScreen — pass weekStartDay (#11)

**Modify:** `lib/features/calendar/calendar_screen.dart`

- [ ] Read weekStartDay from settingsRepositoryProvider, pass to CalendarGrid

---

### Task 6: DB migration — add reminderDays to Expenses (#12)

**Modify:** `lib/data/tables/expenses_table.dart`
**Modify:** `lib/data/database/app_database.dart`

- [ ] Add `IntColumn get reminderDays => integer().nullable()();` to Expenses table
- [ ] Bump schemaVersion to 5, add `if (from < 5) await m.addColumn(expenses, expenses.reminderDays);`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`

---

### Task 7: NotificationService (#12)

**Create:** `lib/core/services/notification_service.dart`

- [ ] `init()` — initialize FlutterLocalNotificationsPlugin
- [ ] `requestPermission()` — request OS permission
- [ ] `scheduleForOccurrence({occurrenceId, name, amount, currency, dueDate, reminderDays})` — schedule at 9am on (dueDate - reminderDays days); skip if in past
- [ ] `cancelForOccurrence(int id)` — cancel by occurrence ID

---

### Task 8: Provider + main.dart init (#12)

**Modify:** `lib/core/providers/settings_providers.dart`
**Modify:** `lib/main.dart`

- [ ] Add `notificationServiceProvider` (Provider<NotificationService>)
- [ ] In main.dart: WidgetsFlutterBinding.ensureInitialized(), init timezone (tz.initializeTimeZones()), init NotificationService

---

### Task 9: AddExpenseForm — reminder picker + schedule (#12)

**Modify:** `lib/features/calendar/widgets/add_expense_form.dart`

- [ ] Add `int? _reminderDays` state (null = no reminder)
- [ ] Add DropdownButtonFormField with options: null (No reminder), 0 (Same day), 1, 2, 7
- [ ] After saving: if reminderDays != null, fetch generated occurrences and schedule notifications for each
- [ ] On first reminder selection: call requestPermission()

---

### Task 10: DaySheet — cancel notifications (#12)

**Modify:** `lib/features/calendar/widgets/day_sheet.dart`

- [ ] `_togglePaid`: if marking paid, cancel notification for occurrence.id
- [ ] `_toggleSkip`: if marking skipped, cancel notification for occurrence.id
- [ ] `_cancelSeries`: before deleting, query occurrence IDs to cancel, then cancel each

---

### Task 11: Android manifest — notification permissions (#12)

**Modify:** `android/app/src/main/AndroidManifest.xml`

- [ ] Add POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED permissions

---

### Task 12: Add getAllOccurrencesWithDetails to DAO (#13)

**Modify:** `lib/data/database/app_database.dart`

- [ ] Add `Future<List<OccurrenceWithDetails>> getAllOccurrencesWithDetails()` to ExpenseOccurrencesDao

---

### Task 13: CsvExportService (#13)

**Create:** `lib/core/services/csv_export_service.dart`

- [ ] `export(dao, currency)` — fetch all occurrences, build CSV string, write to temp file, share

---

### Task 14: Settings Screen — full UI (#11 + #13)

**Modify:** `lib/features/settings/settings_screen.dart`

- [ ] Currency picker (SegmentedButton or DropdownButton)
- [ ] Default frequency picker
- [ ] Week start day toggle (Mon / Sun)
- [ ] Theme picker (Light / Dark / System)
- [ ] Categories link (existing)
- [ ] Export CSV button

---

### Task 15: PR

- [ ] `git add`, commit with `feat(settings,notifications,export): implement #11 #12 #13`
- [ ] `gh pr create` targeting main
