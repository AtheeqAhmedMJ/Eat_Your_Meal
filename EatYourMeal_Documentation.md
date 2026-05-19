# Eat Your Meal — Official Contributor Documentation

> **Version:** 1.0.0+1 · **Framework:** Flutter (Dart ≥ 3.2.0) · **Platforms:** Android · iOS · macOS

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Overview](#2-architecture-overview)
3. [Project Structure](#3-project-structure)
4. [Dependencies](#4-dependencies)
5. [File-by-File Code Reference](#5-file-by-file-code-reference)
   - 5.1 [main.dart](#51-maindart)
   - 5.2 [models/food\_log\_entry.dart](#52-modelsfood_log_entrydart)
   - 5.3 [models/meal\_reminder.dart](#53-modelsmeal_reminderdart)
   - 5.4 [services/app\_state.dart](#54-servicesapp_statedart)
   - 5.5 [services/storage\_service.dart](#55-servicesstorage_servicedart)
   - 5.6 [services/notification\_service.dart](#56-servicesnotification_servicedart)
   - 5.7 [utils/app\_theme.dart](#57-utilsapp_themedart)
   - 5.8 [widgets/gradient\_scaffold.dart](#58-widgetsgradient_scaffolddart)
   - 5.9 [widgets/glass\_card.dart](#59-widgetsglass_carddart)
   - 5.10 [widgets/emoji\_picker.dart](#510-widgetsemoji_pickerdart)
   - 5.11 [widgets/food\_log\_tile.dart](#511-widgetsfood_log_tiledart)
   - 5.12 [widgets/reminder\_tile.dart](#512-widgetsreminder_tiledart)
   - 5.13 [screens/home\_screen.dart](#513-screenshome_screendart)
   - 5.14 [screens/diary\_tab.dart](#514-screensdiary_tabdart)
   - 5.15 [screens/reminders\_tab.dart](#515-screensreminders_tabdart)
   - 5.16 [screens/add\_log\_screen.dart](#516-screensadd_log_screendart)
   - 5.17 [screens/add\_reminder\_screen.dart](#517-screensadd_reminder_screendart)
   - 5.18 [test/widget\_test.dart](#518-testwidget_testdart)
6. [Data Flow](#6-data-flow)
7. [Notification System Deep Dive](#7-notification-system-deep-dive)
8. [Theme System Deep Dive](#8-theme-system-deep-dive)
9. [How to Contribute](#9-how-to-contribute)
10. [Known Limitations & Future Work](#10-known-limitations--future-work)

---

## 1. Project Overview

**Eat Your Meal** is a cross-platform Flutter app that helps users build healthier eating habits through two core features:

- **Meal Reminders** — scheduled local notifications (daily, weekdays, weekends, or once) that prompt the user to eat.
- **Food Diary** — a date-browsable log where users record what they actually ate, how it looked (emoji), and how they felt (mood).

All data lives **on-device** — there is no backend, no account required, and no network calls. The app uses `shared_preferences` for persistence and `flutter_local_notifications` + `timezone` for scheduling.

---

## 2. Architecture Overview

The app follows a **Provider + Service** pattern:

```
UI (Screens & Widgets)
        │
        ▼  reads/writes via
   AppState (ChangeNotifier)
        │
        ├──► StorageService   (SharedPreferences persistence)
        └──► NotificationService (flutter_local_notifications scheduling)
```

- **`AppState`** is the single source of truth. It holds the in-memory lists of reminders and food logs and exposes async mutation methods. Widgets observe it via `context.watch<AppState>()`.
- **`StorageService`** is a singleton that reads/writes JSON to `SharedPreferences`. It never holds state; it only serializes and deserializes.
- **`NotificationService`** is a singleton that wraps `FlutterLocalNotificationsPlugin`. It schedules or cancels platform notifications whenever reminders change.
- **Models** (`MealReminder`, `FoodLogEntry`) are plain Dart classes with `toMap` / `fromMap` / JSON helpers. They carry no business logic.
- **Screens** never call `StorageService` or `NotificationService` directly — they always go through `AppState`.

---

## 3. Project Structure

```
lib/
├── main.dart                  # App entry point, app widget, gate widget
├── models/
│   ├── food_log_entry.dart    # Data model for one meal log
│   └── meal_reminder.dart     # Data model + RepeatMode enum for reminders
├── services/
│   ├── app_state.dart         # ChangeNotifier — all business logic
│   ├── storage_service.dart   # SharedPreferences read/write wrapper
│   └── notification_service.dart  # Local notification scheduling
├── utils/
│   └── app_theme.dart         # Color palette, gradients, ThemeData, helpers
├── widgets/
│   ├── gradient_scaffold.dart # Transparent Scaffold wrapper
│   ├── glass_card.dart        # Reusable frosted-glass card widget
│   ├── emoji_picker.dart      # Bottom-sheet emoji picker
│   ├── food_log_tile.dart     # Slidable row for a food log entry
│   └── reminder_tile.dart     # Slidable row for a reminder
└── screens/
    ├── home_screen.dart       # Root tab shell (Reminders | Diary)
    ├── reminders_tab.dart     # Lists all reminders
    ├── diary_tab.dart         # Date-picker + logs for selected day
    ├── add_reminder_screen.dart  # Create / edit a reminder
    └── add_log_screen.dart    # Create / edit a food log entry

test/
└── widget_test.dart           # Smoke test — app renders without error

assets/                        # Asset folder (declared in pubspec.yaml)
```

---

## 4. Dependencies

All dependencies are declared in `pubspec.yaml`.

| Package | Version | Purpose |
|---|---|---|
| `flutter_local_notifications` | ^17.2.2 | Schedule / cancel local push notifications |
| `timezone` | ^0.9.4 | Timezone-aware `TZDateTime` for precise scheduling |
| `shared_preferences` | ^2.2.3 | Key-value on-device persistence |
| `path_provider` | ^2.1.3 | File-system path access (pulled in by other deps) |
| `flutter_slidable` | ^3.1.1 | Swipe-to-reveal edit/delete actions on list tiles |
| `intl` | ^0.19.0 | Date/time formatting (`DateFormat`) |
| `flutter_animate` | ^4.5.0 | Declarative `fadeIn`, `slideX`, `scale` animations |
| `uuid` | ^4.4.2 | RFC 4122 v4 UUID generation for unique IDs |
| `provider` | ^6.1.2 | `ChangeNotifier`-based DI / state management |
| `permission_handler` | ^11.3.1 | Runtime notification permission requests |

**Dev dependencies:**

| Package | Purpose |
|---|---|
| `flutter_test` | Built-in Flutter testing framework |
| `flutter_lints` | Dart lint rules for code quality |

---

## 5. File-by-File Code Reference

---

### 5.1 `main.dart`

**Role:** App entry point. Initialises services, wires up Provider, and defines the top-level widget tree.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
```
`ensureInitialized()` must be called before any async work in `main` — it boots the Flutter engine bindings so platform channels are ready.

```dart
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
```
Makes the Android status bar transparent with dark icons so the app's light gradient shows through.

```dart
  await NotificationService.instance.init();
```
Initialises the notification plugin and timezone database before the widget tree is built. This must be `await`-ed — failing to do so means `scheduleReminder` could fire before the plugin is ready.

```dart
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const EatYourMealApp(),
    ),
  );
```
Creates the single `AppState` instance and calls `init()` (loads persisted data) immediately. `ChangeNotifierProvider` makes it available to every widget in the tree.

---

#### `EatYourMealApp`

```dart
class EatYourMealApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eat Your Meal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: child!,
      ),
      home: const _AppGate(),
    );
  }
}
```
The `builder` wraps the entire app in a gradient `Container`. Because `Scaffold` sets `backgroundColor: Colors.transparent` throughout the app, the gradient bleeds through every screen — giving a consistent tinted background without repeating the gradient widget on every page.

---

#### `_AppGate`

A `StatefulWidget` that shows a splash screen while `AppState.loading` is true, then renders `HomeScreen`.

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final state = context.watch<AppState>();
  if (!state.loading && !_permAsked) {
    _permAsked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await NotificationService.instance.requestPermission();
      for (final r in state.reminders) {
        if (r.enabled) await NotificationService.instance.scheduleReminder(r);
      }
    });
  }
}
```
`didChangeDependencies` runs whenever a watched dependency (here `AppState`) changes. The `_permAsked` guard prevents asking for permission more than once. `addPostFrameCallback` defers the async work until after the build is complete — necessary because you cannot perform navigation or dialog actions during a `build` call.

The splash body shows the 🍽️ emoji and the app title while `state.loading` is true:

```dart
if (state.loading) {
  return const Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🍽️', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('Eat Your Meal', ...),
        ],
      ),
    ),
  );
}
return const HomeScreen();
```

---

### 5.2 `models/food_log_entry.dart`

**Role:** Immutable-ish data object representing one meal the user logged.

#### Fields

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4, unique per entry |
| `date` | `DateTime` | The calendar day this entry belongs to |
| `mealName` | `String` | Linked reminder name or a custom name entered by the user |
| `emoji` | `String` | Single emoji character representing the meal |
| `notes` | `String` | Free-text description of what was eaten (mutable — can be edited) |
| `mood` | `String?` | Optional mood emoji selected after eating |
| `loggedAt` | `DateTime` | The exact timestamp of when the entry was created |

`notes` is `var` (mutable), while the rest are `final`. This is intentional — the edit screen creates a new `FoodLogEntry` with the same `id` and `loggedAt`, preserving identity while updating content.

#### Serialization

```dart
Map<String, dynamic> toMap() => {
  'id': id,
  'date': date.toIso8601String(),
  'mealName': mealName,
  'emoji': emoji,
  'notes': notes,
  'mood': mood,
  'loggedAt': loggedAt.toIso8601String(),
};

factory FoodLogEntry.fromMap(Map<String, dynamic> m) => FoodLogEntry(
  id: m['id'],
  date: DateTime.parse(m['date']),
  ...
);
```
`DateTime` fields are stored as ISO 8601 strings because `SharedPreferences` only supports `String`, `int`, `double`, `bool`, and `List<String>`. The JSON helpers (`toJson` / `fromJson`) call `jsonEncode`/`jsonDecode` on top of `toMap`/`fromMap`.

#### `kMoodEmojis`

```dart
const List<String> kMoodEmojis = ['😊', '😋', '🤩', '😐', '😴', '🤢', '💪'];
```
A global constant list of mood emojis shown in the "How do you feel?" section of `AddLogScreen`. Adding a new mood requires adding it here.

---

### 5.3 `models/meal_reminder.dart`

**Role:** Represents a scheduled meal reminder, including its repeat schedule and enabled state.

#### Fields

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4, also used to derive notification IDs |
| `name` | `String` | Human-readable name (e.g. "Lunch") |
| `emoji` | `String` | Icon shown in the notification and the list |
| `timeStr` | `String` | 24-hour time as `"HH:mm"` (e.g. `"13:20"`) |
| `repeat` | `RepeatMode` | Enum: daily / weekdays / weekends / once |
| `enabled` | `bool` | Whether the notification is active |
| `createdAt` | `DateTime` | Creation timestamp |

#### `copyWith`

```dart
MealReminder copyWith({
  String? name, String? emoji, String? timeStr,
  RepeatMode? repeat, bool? enabled,
}) => MealReminder(id: id, ..., createdAt: createdAt);
```
`copyWith` is the standard immutable-update pattern in Dart. It preserves `id` and `createdAt` (identity fields), while allowing any other field to be overridden. Used by `AppState.toggleReminder` and `AddReminderScreen._save`.

#### `RepeatMode` enum

```dart
enum RepeatMode { daily, weekdays, weekends, once }
```
Stored as its integer index (`repeat.index`) in the JSON map. When loading, it is restored via `RepeatMode.values[m['repeat'] ?? 0]`. The `?? 0` default means any entry without a stored repeat defaults to `daily`.

#### `RepeatModeLabel` extension

```dart
extension RepeatModeLabel on RepeatMode {
  String get label { ... }     // "Every Day", "Weekdays", etc.
  String get shortLabel { ... } // "Daily", "Mon–Fri", etc.
}
```
Extensions keep display-logic separate from the model. `label` is used in the `AddReminderScreen` chip selector; `shortLabel` is used in the compact `ReminderTile`.

---

### 5.4 `services/app_state.dart`

**Role:** The application's single ChangeNotifier. All business logic lives here. Screens read from it and call its methods — they never call `StorageService` or `NotificationService` directly.

#### State fields

```dart
List<MealReminder> reminders = [];
List<FoodLogEntry> foodLogs = [];
bool loading = true;
bool _disposed = false;
```
`_disposed` guards against calling `notifyListeners()` after the object is disposed, which would throw in debug mode.

#### `_notify()`

```dart
void _notify() {
  if (!_disposed) notifyListeners();
}
```
All internal state changes call `_notify()` instead of `notifyListeners()` directly. This pattern is robust across async operations where the widget tree may have been torn down.

#### `init()`

```dart
Future<void> init() async {
  reminders = await StorageService.instance.loadReminders();
  if (reminders.isEmpty) {
    reminders = _defaultReminders();
    await StorageService.instance.saveReminders(reminders);
    for (final reminder in reminders) {
      await NotificationService.instance.scheduleReminder(reminder);
    }
  }
  foodLogs = await StorageService.instance.loadLogs();
  loading = false;
  _notify();
}
```
Called immediately after construction (via `AppState()..init()`). If the user has no reminders stored yet (first launch), it seeds four default reminders (Breakfast, Lunch, Snacks, Dinner) and schedules their notifications.

#### `_defaultReminders()`

Returns four pre-configured `MealReminder` objects:

| Name | Emoji | Time |
|---|---|---|
| Break fast | 🥐 | 08:30 |
| Lunch | 🥗 | 13:20 |
| Snacks | 🍎 | 17:30 |
| Dinner | 🍽️ | 20:30 |

All are daily and enabled by default.

#### Reminder CRUD

```dart
Future<void> addReminder(MealReminder r) async {
  reminders.add(r);
  await StorageService.instance.saveReminders(reminders);
  await NotificationService.instance.scheduleReminder(r);
  _notify();
}
```
Every mutation method follows the same three-step pattern: **update in-memory list → persist → sync notifications → notify UI**. This keeps all three layers consistent after every change.

```dart
Future<void> toggleReminder(String id) async {
  final idx = reminders.indexWhere((r) => r.id == id);
  if (idx == -1) return;
  reminders[idx] = reminders[idx].copyWith(enabled: !reminders[idx].enabled);
  await StorageService.instance.saveReminders(reminders);
  await NotificationService.instance.scheduleReminder(reminders[idx]);
  _notify();
}
```
Toggling passes the updated reminder to `scheduleReminder`. Inside that method, if `!reminder.enabled`, `cancelReminder` is called and the function returns early — so "toggling off" effectively cancels all related notifications.

```dart
Future<void> deleteReminder(String id) async {
  await NotificationService.instance.cancelReminder(id);  // cancel FIRST
  reminders.removeWhere((r) => r.id == id);
  await StorageService.instance.saveReminders(reminders);
  _notify();
}
```
`cancelReminder` is called *before* the reminder is removed from the list. If the order were reversed and cancellation failed, the notification could remain orphaned (no way to cancel it later since the id is gone).

#### Food log CRUD

```dart
Future<void> addLog(FoodLogEntry e) async { ... }
Future<void> updateLog(FoodLogEntry updated) async { ... }
Future<void> deleteLog(String id) async { ... }
```
Mirrors the reminder pattern, but without any notification interaction.

#### `logsForDate(DateTime date)`

```dart
List<FoodLogEntry> logsForDate(DateTime date) => foodLogs
    .where((l) =>
        l.date.year == date.year &&
        l.date.month == date.month &&
        l.date.day == date.day)
    .toList()
  ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
```
Filters the flat `foodLogs` list by calendar day (year + month + day comparison avoids timezone issues from comparing full `DateTime` objects) and sorts by `loggedAt` so entries appear in the order they were recorded.

#### `newId()`

```dart
String newId() => _uuid.v4();
```
Generates a UUID v4. Centralised here so screens don't need to import `uuid` directly.

---

### 5.5 `services/storage_service.dart`

**Role:** Thin persistence layer. Reads and writes serialized JSON strings to `SharedPreferences`.

```dart
class StorageService {
  StorageService._();                         // private constructor
  static final StorageService instance = StorageService._(); // singleton
```
The `._()` constructor pattern creates a private named constructor, making it impossible to instantiate `StorageService` from outside the class. The single `instance` is created lazily when first accessed.

#### Storage keys

```dart
static const _remindersKey = 'reminders_v2';
static const _logsKey = 'food_logs_v2';
```
The `_v2` suffix is a versioning strategy. If the data format changes in a future release, bump the key suffix so old data is ignored instead of causing a parse crash. **Contributors: if you change the model schema, bump these keys and write a migration if needed.**

#### `loadReminders()`

```dart
Future<List<MealReminder>> loadReminders() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(_remindersKey) ?? [];
  return raw
      .map((s) {
        try { return MealReminder.fromJson(s); }
        catch (_) { return null; }
      })
      .whereType<MealReminder>()
      .toList();
}
```
`getStringList` returns `null` if the key doesn't exist — the `?? []` fallback handles first launch. Each JSON string is parsed inside a `try/catch` so a single corrupted entry doesn't crash the whole load. `whereType<MealReminder>()` filters out the `null` values from failed parses.

`saveLogs` and `loadLogs` follow the exact same pattern for `FoodLogEntry`.

---

### 5.6 `services/notification_service.dart`

**Role:** Manages all interaction with the platform's notification system. Schedules timezone-aware repeating notifications and handles cancellation.

#### Singleton & plugin

```dart
final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();
bool _initialized = false;
```
`_initialized` guards against double-init (which can cause plugin errors).

#### `init()`

```dart
Future<void> init() async {
  if (_initialized) return;
  tz_data.initializeTimeZones();           // loads the IANA timezone database
  try {
    tz.setLocalLocation(tz.getLocation(_detectTzName()));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);           // safe fallback
  }

  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(...),
    macOS: DarwinInitializationSettings(...),
  );
  await _plugin.initialize(settings,
      onDidReceiveNotificationResponse: (_) {});
  _initialized = true;
}
```
`initializeTimeZones()` must be called before any `tz.getLocation(...)` call — it loads the bundled IANA database into memory. The `onDidReceiveNotificationResponse` callback is a placeholder; you can use it to deep-link into the app when the user taps a notification.

#### `_detectTzName()`

```dart
String _detectTzName() {
  try {
    final name = DateTime.now().timeZoneName;
    tz.getLocation(name);
    return name;
  } catch (_) {
    final h = DateTime.now().timeZoneOffset.inMinutes;
    const map = {
      330: 'Asia/Kolkata',
      0: 'Europe/London',
      ...
    };
    return map[h] ?? 'UTC';
  }
}
```
On most devices, `DateTime.now().timeZoneName` returns a valid IANA name (e.g. `"Asia/Kolkata"`). On some Android devices it returns an abbreviation (e.g. `"IST"`) which the `timezone` package cannot resolve. The fallback maps UTC offset in minutes to a known IANA name. **Contributors: if you need to support additional offsets, add them to the `map`.**

#### `requestPermission()`

Resolves the platform-specific plugin implementation and requests notification permission:

```dart
final android = _plugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();
if (android != null) {
  return (await android.requestNotificationsPermission()) ?? false;
}
```
Returns `true` if permission was granted, `false` otherwise. The return value is currently unused by callers — you could use it to show a rationale dialog.

#### `scheduleReminder(MealReminder meal)`

```dart
Future<void> scheduleReminder(MealReminder meal) async {
  await cancelReminder(meal.id);   // clear existing slots before rescheduling
  if (!meal.enabled) return;
  ...
  for (final day in _daysForRepeat(meal.repeat)) {
    final id = _notifId(meal.id, day);
    final scheduledDate = _nextOccurrence(hour, minute, day);
    await _plugin.zonedSchedule(
      id,
      '${meal.emoji}  ${meal.name}',
      'Time to eat! Log what you had in Eat Your Meal.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: meal.repeat == RepeatMode.once
          ? null
          : DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
```
The key design: a `daily` reminder schedules **7 separate notifications** (one per weekday), a `weekdays` reminder schedules 5, and so on. Each gets a unique numeric ID derived from the reminder's UUID and the weekday number.

`matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime` tells the plugin to **repeat** the notification every week on the same day at the same time. `RepeatMode.once` passes `null`, so it fires only once.

`AndroidScheduleMode.exactAllowWhileIdle` ensures the notification fires even if the device is in Doze mode — important for meal reminders which must arrive on time.

#### `_daysForRepeat(RepeatMode mode)`

```dart
List<int> _daysForRepeat(RepeatMode mode) {
  switch (mode) {
    case RepeatMode.daily:    return [1, 2, 3, 4, 5, 6, 7];
    case RepeatMode.weekdays: return [1, 2, 3, 4, 5];
    case RepeatMode.weekends: return [6, 7];
    case RepeatMode.once:     return [0]; // 0 = special "no weekday filter"
  }
}
```
Weekday integers follow ISO 8601: 1 = Monday, 7 = Sunday. `0` is used as a sentinel for "once".

#### `_notifId(String mealId, int day)`

```dart
int _notifId(String mealId, int day) =>
    (mealId.hashCode.abs() * 10 + day) % 2147483647;
```
Maps the string UUID + weekday to a stable 32-bit integer. The `% 2147483647` ensures the value fits in a signed 32-bit int (the max supported notification ID on Android). **Hash collisions are theoretically possible** — this is a known limitation for future improvement.

#### `cancelReminder(String mealId)`

```dart
Future<void> cancelReminder(String mealId) async {
  for (int d = 0; d <= 7; d++) {
    await _plugin.cancel(_notifId(mealId, d));
  }
}
```
Cancels IDs 0–7 for the given `mealId`, covering all possible weekday slots.

#### `_nextOccurrence(int hour, int minute, int isoWeekday)`

```dart
tz.TZDateTime _nextOccurrence(int hour, int minute, int isoWeekday) {
  final now = tz.TZDateTime.now(tz.local);
  var c = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (isoWeekday == 0) {
    if (c.isBefore(now)) c = c.add(const Duration(days: 1));
    return c;
  }
  int tries = 0;
  while (c.weekday != isoWeekday || !c.isAfter(now)) {
    c = c.add(const Duration(days: 1));
    if (++tries > 14) break;  // safety guard
  }
  return c;
}
```
Finds the next calendar occurrence of a given weekday + time that is strictly in the future. The `tries > 14` guard prevents an infinite loop if `isoWeekday` is somehow out of range.

---

### 5.7 `utils/app_theme.dart`

**Role:** Centralised design system. All colors, gradients, card decorations, and the `ThemeData` are defined here. No widget should hardcode colours.

#### Palette

| Constant | Hex | Usage |
|---|---|---|
| `primary` | `#1F2933` | Ink charcoal — buttons, active states, text |
| `secondary` | `#4B5563` | Soft slate — secondary text, chips |
| `accent` | `#7C8A9F` | Washed ink — FABs, emoji highlights |
| `bgTop` | `#F6F7F9` | Rice paper — gradient top |
| `bgBottom` | `#E7ECF2` | Misted grey — gradient bottom |
| `surface` | `#FDFDFD` | Card base colour |
| `textDark` | `#111827` | Primary text |
| `textMid` | `#4B5563` | Secondary text |
| `textLight` | `#6B7280` | Hints, labels, timestamps |

#### `glassCard()` factory method

```dart
static BoxDecoration glassCard({
  double borderRadius = 20,
  Color? tint,
  double opacity = 0.75,
}) => BoxDecoration(
  color: (tint ?? surface).withAlphaPercent(opacity),
  borderRadius: BorderRadius.circular(borderRadius),
  border: Border.all(color: cardBorder, width: 1.5),
  boxShadow: [
    BoxShadow(color: Colors.white.withAlphaPercent(0.6), ...),  // highlight
    BoxShadow(color: primary.withAlphaPercent(0.08), ...),       // shadow
  ],
);
```
The dual-shadow technique (a light shadow top-left + a dark shadow bottom-right) creates the "neumorphic" / frosted-glass depth effect. This static method is used by `GlassCard` widget but can also be applied directly to any `Container`.

#### `ColorOpacityExtensions`

```dart
extension ColorOpacityExtensions on Color {
  Color withAlphaPercent(double opacity) =>
      withAlpha((opacity.clamp(0.0, 1.0) * 0xFF).round());
}
```
Flutter's `withOpacity()` was deprecated in favour of `withAlpha()`. This extension provides a clean API that accepts a 0.0–1.0 float. **All opacity calls in the project use this extension — never use `withOpacity()` in new code.**

#### `ThemeData light`

Customizes Material 3 components to match the design system:

- **Font:** `Futura` (custom font — must be declared in assets if added)
- **AppBar:** transparent background, no elevation
- **ElevatedButton:** `primary` background, rounded corners, no elevation
- **InputDecoration:** semi-transparent white fill, rounded borders, 2px primary border on focus
- **Chip:** white fill, rounded, primary tint when selected

---

### 5.8 `widgets/gradient_scaffold.dart`

**Role:** A `Scaffold` wrapper with `backgroundColor: Colors.transparent`, allowing the global gradient from `MaterialApp`'s `builder` to show through.

```dart
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }
}
```
Used by `AddLogScreen` and `AddReminderScreen`. The screens inside `HomeScreen` use plain `Scaffold` with `backgroundColor: Colors.transparent` directly, since `HomeScreen` manages the outer structure.

---

### 5.9 `widgets/glass_card.dart`

**Role:** Reusable frosted-glass card with optional tap interaction.

```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;    // default 20
  final EdgeInsetsGeometry padding;  // default EdgeInsets.all(16)
  final Color? tint;            // optional colour overlay
  final VoidCallback? onTap;    // if provided, wraps in InkWell

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppTheme.primary.withAlphaPercent(0.08),
        highlightColor: Colors.transparent,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (tint ?? Colors.white).withAlphaPercent(0.72),
            ...dual shadows...
          ),
          child: child,
        ),
      ),
    );
  }
}
```
The `Material` + `InkWell` wrapping is necessary to get the ink splash effect on top of a custom `BoxDecoration` background. If you only used `GestureDetector`, taps would work but there would be no visual ripple feedback.

---

### 5.10 `widgets/emoji_picker.dart`

**Role:** A bottom-sheet that lets the user pick an emoji for a meal or reminder.

#### `kMealEmojis`

```dart
const List<String> kMealEmojis = [
  '🍳', '🥣', '🥪', '🍛', '🍜', '🍝', '🥗', '🍲', '🥩', '🍱',
  '🍔', '🌮', '🍕', '🥙', '🍣', '🍤', '🥘', '🍚', '🍞', '🥞',
  '🧆', '🍗', '🥦', '🫕', '🥚', '🧀', '🍎', '🫐', '🥑', '🍜',
];
```
30 meal emojis shown in a `Wrap` grid. **To add new emojis, append to this list.**

#### `EmojiPicker` widget

A `StatefulWidget` that tracks `_current` (the presently-selected emoji). When the user taps an emoji:

```dart
onTap: () {
  setState(() => _current = e);
  Navigator.pop(context, e);   // returns the chosen emoji to the caller
},
```
The selected emoji is highlighted with a primary-tinted border. `AnimatedContainer` provides a smooth 150ms selection transition.

#### `showEmojiPicker()` helper

```dart
Future<String?> showEmojiPicker(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => EmojiPicker(selected: current),
  );
}
```
Returns `null` if the user dismissed the sheet without selecting. Callers check for `null` before applying the result.

---

### 5.11 `widgets/food_log_tile.dart`

**Role:** A list item for a single `FoodLogEntry`. Supports swipe-to-reveal edit/delete and a three-dot menu.

```dart
Slidable(
  key: ValueKey(entry.id),   // unique key prevents animation glitches during reorder
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [
      SlidableAction(onPressed: (_) => onEdit(), icon: Icons.edit_rounded, label: 'Edit'),
      SlidableAction(onPressed: (_) => onDelete(), icon: Icons.delete_rounded, label: 'Delete'),
    ],
  ),
  child: GlassCard(
    onTap: onEdit,
    child: Row(
      children: [
        // Emoji badge (48×48 rounded container)
        Container(width: 48, height: 48, ...child: Text(entry.emoji)),
        // Right: mealName, notes (2-line truncated), timestamp
        Expanded(child: Column(...)),
        // Three-dot PopupMenuButton (edit / delete)
        PopupMenuButton(...)
      ],
    ),
  ),
).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
```
The `.animate()` chain at the end makes each tile fade in and slide slightly from the right when it first appears in the list.

The `PopupMenuButton` and the `Slidable` both offer the same edit/delete actions — the menu is for discoverability on desktop/tablet, the swipe is for mobile convenience.

---

### 5.12 `widgets/reminder_tile.dart`

**Role:** A list item for a `MealReminder`. Includes a live countdown, a toggle switch, and swipe actions.

#### `_fmt12(String timeStr)` — 12-hour formatting

```dart
String _fmt12(String timeStr) {
  final parts = timeStr.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final ampm = h < 12 ? 'AM' : 'PM';
  final hh = h % 12 == 0 ? 12 : h % 12;
  return '$hh:${m.toString().padLeft(2, '0')} $ampm';
}
```
Converts the stored `"HH:mm"` 24-hour format to a display-friendly 12-hour format. `h % 12 == 0 ? 12 : h % 12` correctly maps `0:xx` → `12:xx AM` and `12:xx` → `12:xx PM`.

#### `_countdown(String timeStr)` — live time-to-fire display

```dart
String _countdown(String timeStr) {
  ...
  if (target.isBefore(now)) target = target.add(const Duration(days: 1));
  final diff = target.difference(now);
  if (diff.inMinutes < 1) return 'Any moment…';
  if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
  return mins == 0 ? 'In ${hrs}h' : 'In ${hrs}h ${mins}m';
}
```
Shows the next firing time relative to now. Since it always adds a day if the time has passed, it always shows the time until the *next* occurrence. **Note:** this is computed at build time, not live-ticking — it updates whenever the widget rebuilds (e.g., when the user navigates back to the screen).

#### Adaptive disabled state

When `reminder.enabled` is false, the tile visually dims:
- Emoji bubble: grey tint instead of primary tint
- Name: grey with `TextDecoration.lineThrough`
- Countdown: hidden

---

### 5.13 `screens/home_screen.dart`

**Role:** The root shell. Hosts the bottom navigation bar and the `TabBarView` switching between `RemindersTab` and `DiaryTab`.

#### Responsive layout

```dart
return LayoutBuilder(builder: (context, constraints) {
  final isWide = constraints.maxWidth >= 760;
  final navHeight = isWide ? 90.0 : 72.0;
  final iconSize = isWide ? 26.0 : 22.0;
  ...
});
```
`LayoutBuilder` adapts to screen width. On tablets or desktop (≥760px), the nav bar is taller and icons are larger. The bottom nav also spreads items with `MainAxisAlignment.spaceAround` on wide screens vs `spaceEvenly` on narrow ones.

#### `TabController` + `AnimatedSwitcher`

```dart
_tabController = TabController(length: 2, vsync: this);
_tabController.addListener(() {
  if (!_tabController.indexIsChanging) {
    setState(() => _tab = _tabController.index);
  }
});
```
`_tabController` drives the `TabBarView`. The listener syncs `_tab` (used to highlight the selected nav item) with the controller, but only when the animation has completed (`!indexIsChanging`).

The body uses `AnimatedSwitcher` for a fade + slide transition when changing tabs:

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 420),
  switchInCurve: Curves.easeOutCubic,
  transitionBuilder: (child, animation) =>
    FadeTransition(opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
            .animate(animation),
        child: child)),
  child: SizedBox(key: ValueKey<int>(_tab), child: TabBarView(...)),
),
```
The `ValueKey<int>(_tab)` on the `SizedBox` tells `AnimatedSwitcher` that the child has changed and an animation should run.

#### `_BottomNav` — pill-shaped active indicator

The selected tab item renders with its label and a rounded-rectangle background:

```dart
AnimatedContainer(
  decoration: BoxDecoration(
    color: sel ? AppTheme.primary.withAlphaPercent(0.18) : Colors.transparent,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(children: [
    Icon(sel ? active : inactive, ...),
    if (sel) Text(label, ...),
  ]),
)
```
`AnimatedContainer` smoothly transitions the background colour. The label only appears for the selected tab, creating a "pill" effect.

---

### 5.14 `screens/diary_tab.dart`

**Role:** Displays a 14-day horizontal date strip and the food log entries for the selected date.

#### `_DiaryTabState` — selected date

```dart
DateTime _selectedDate = DateTime.now();
```
The tab is stateful because it owns the currently-selected date. When the user taps a different day, `setState` updates `_selectedDate` and the sliver list re-renders.

#### `_dateStrip()`

```dart
final days = List.generate(14, (i) => today.subtract(Duration(days: 13 - i)));
```
Generates 14 days ending at today (days[13] = today). The selected day gets the `primaryGradient` background; today (if not selected) gets a faint primary border to distinguish it.

#### `CustomScrollView` with Slivers

The body uses `CustomScrollView` with:
- `SliverToBoxAdapter` for the date strip
- `SliverToBoxAdapter` for the day header (`GlassCard` showing entry count)
- `SliverToBoxAdapter` for the empty state, or `SliverList` for log tiles
- A final `SliverToBoxAdapter(child: SizedBox(height: 100))` to prevent the FAB from covering the last item

#### FAB — Log Meal

```dart
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AddLogScreen(date: _selectedDate),
  ),
),
```
Passes the currently-selected date so new entries are automatically attributed to the correct day.

---

### 5.15 `screens/reminders_tab.dart`

**Role:** Shows all reminders with a stats bar at the top.

#### `_statsBar()`

```dart
_stat(context, '$enabled', 'Active', AppTheme.primary),
_divider(),
_stat(context, '${total - enabled}', 'Paused', AppTheme.textLight),
_divider(),
_stat(context, '$total', 'Total', AppTheme.accent),
```
Three columns in a `GlassCard` showing active, paused, and total counts. Each `_stat` is an `Expanded` column so they share width equally.

#### `_confirmDelete()` — delete guard dialog

```dart
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Delete Reminder?'),
    content: Text('Are you sure you want to delete "$name"?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      TextButton(
        onPressed: () { state.deleteReminder(id); Navigator.pop(ctx); },
        child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
      ),
    ],
  ),
);
```
Deleting a reminder is destructive (it also cancels its notification), so a confirmation dialog is shown. Food log deletion in `DiaryTab` does not show a dialog — it happens immediately via swipe.

---

### 5.16 `screens/add_log_screen.dart`

**Role:** Full-screen form for creating or editing a food log entry. Also accepts `FoodLogEntry? existing` — when non-null, the screen enters edit mode.

#### Mode detection

```dart
bool get _isEdit => widget.existing != null;
```
Used throughout `build` and `_save` to alter labels ("Log Meal" vs "Edit Log", "Log Meal" button vs "Save Changes") and to decide whether to call `state.addLog` or `state.updateLog`.

#### Initialisation

```dart
@override
void initState() {
  super.initState();
  final e = widget.existing;
  _nameCtrl = TextEditingController(text: e?.mealName ?? '');
  _notesCtrl = TextEditingController(text: e?.notes ?? '');
  _emoji = e?.emoji ?? '🍽️';
  _mood = e?.mood;
}
```
Pre-populates controllers from the existing entry in edit mode, or starts blank for new entries.

#### Quick-fill chips

```dart
if (!_isEdit && reminders.isNotEmpty) ...[
  SizedBox(
    height: 44,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: reminders.length,
      itemBuilder: (ctx, i) {
        final r = reminders[i];
        return ActionChip(
          label: Text('${r.emoji} ${r.name}'),
          onPressed: () {
            setState(() {
              _nameCtrl.text = r.name;
              _emoji = r.emoji;
            });
          },
        );
      },
    ),
  ),
]
```
When creating a new log, a horizontal row of chips lets the user one-tap fill the meal name and emoji from an existing reminder. This is a convenience link between the two features.

#### `_save()`

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;
  if (mounted) setState(() => _saving = true);
  final state = context.read<AppState>();

  if (_isEdit) {
    final updated = FoodLogEntry(
      id: widget.existing!.id,        // preserve original ID
      date: widget.existing!.date,    // preserve original date
      ...
      loggedAt: widget.existing!.loggedAt,  // preserve original timestamp
    );
    await state.updateLog(updated);
  } else {
    final entry = FoodLogEntry(
      id: state.newId(),
      date: widget.date,
      ...
      loggedAt: DateTime.now(),  // timestamp = NOW
    );
    await state.addLog(entry);
  }
  if (mounted) Navigator.pop(context);
}
```
`_saving` disables the button and shows a `CircularProgressIndicator` while the async save is running. `if (mounted)` checks guard against `setState`/`Navigator` calls on a disposed widget.

---

### 5.17 `screens/add_reminder_screen.dart`

**Role:** Full-screen form for creating or editing a `MealReminder`.

#### Time management

```dart
late TimeOfDay _time;

// In initState:
if (e != null) {
  final parts = e.timeStr.split(':');
  _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
} else {
  final now = TimeOfDay.now();
  _time = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
}
```
For new reminders, the default time is the next whole hour. `% 24` wraps midnight correctly (e.g., if it's 23:xx, the default is 0:00).

```dart
String get _timeStr =>
    '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
```
Converts the `TimeOfDay` back to the `"HH:mm"` format expected by `MealReminder.timeStr`. `padLeft(2, '0')` ensures `"08:05"` instead of `"8:5"`.

#### Time picker

```dart
Future<void> _pickTime() async {
  final picked = await showTimePicker(
    context: context,
    initialTime: _time,
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(primary: AppTheme.primary),
      ),
      child: child!,
    ),
  );
  if (picked != null) setState(() => _time = picked);
}
```
The `Theme` wrapper overrides the time picker's primary colour to match the app's design system.

#### Repeat mode selection

```dart
Wrap(
  children: RepeatMode.values.map((mode) {
    final selected = _repeat == mode;
    return ChoiceChip(
      label: Text(mode.label),
      selected: selected,
      onSelected: (_) => setState(() => _repeat = mode),
      selectedColor: AppTheme.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.textMid),
    );
  }).toList(),
)
```
`RepeatMode.values` iterates all enum cases automatically — adding a new `RepeatMode` case will automatically appear here without modifying this screen.

#### `_repeatHint()`

Returns a human-readable sentence explaining what the selected repeat mode means. Shown in small text below the chips.

---

### 5.18 `test/widget_test.dart`

**Role:** Smoke test confirming the app can be instantiated and renders the expected title.

```dart
testWidgets('App renders without errors', (WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MaterialApp(home: EatYourMealApp()),
    ),
  );
  await tester.pump();
  expect(find.text('Eat Your Meal'), findsWidgets);
});
```
This test wraps `EatYourMealApp` in a fresh `ChangeNotifierProvider` to avoid depending on the real `main()`. It calls `pump()` once (not `pumpAndSettle`) to avoid waiting for animations. `findsWidgets` (plural) is used because the title appears in both the AppBar and the splash screen.

**This test will currently fail** because `NotificationService.init()` is not called and `SharedPreferences` is not mocked. Contributors adding tests should use `SharedPreferences.setMockInitialValues({})` and mock the notification plugin.

---

## 6. Data Flow

### Creating a new reminder (full path)

```
User taps "Add Reminder" FAB
  → Navigator.push(AddReminderScreen())
    → User fills form, taps "Set Reminder"
      → _save() called
        → MealReminder created with state.newId()
        → state.addReminder(reminder)
          → reminders.add(reminder)
          → StorageService.saveReminders(reminders)
              → prefs.setStringList('reminders_v2', [...json])
          → NotificationService.scheduleReminder(reminder)
              → _plugin.zonedSchedule(...)  [×N days]
          → notifyListeners()
            → RemindersTab rebuilds with new reminder in list
      → Navigator.pop()
```

### Toggling a reminder off

```
User taps Switch on ReminderTile
  → state.toggleReminder(id)
    → copyWith(enabled: false)
    → StorageService.saveReminders(...)
    → NotificationService.scheduleReminder(updated)
        → cancelReminder(id)   [clears all 7 slots]
        → !enabled → return    [schedules nothing]
    → notifyListeners()
      → ReminderTile rebuilds (dimmed, countdown hidden)
```

---

## 7. Notification System Deep Dive

### ID collision risk

The notification ID formula is:

```
id = (mealId.hashCode.abs() * 10 + day) % 2147483647
```

Two different UUID strings could theoretically produce the same `hashCode` in Dart (hash collisions). If two reminders collide on the same day slot, one would silently overwrite the other's notification. **Improvement:** use a deterministic ID from a counter or a hash with more bits.

### Timezone edge cases

`_detectTzName()` covers only the most common UTC offsets. Users in regions not listed (e.g. India's `+05:30` is covered as `330: 'Asia/Kolkata'`, but `+05:45` Nepal is not) will fall back to `UTC`. **To add coverage, extend the offset map.**

### Android exact alarms (Android 12+)

`AndroidScheduleMode.exactAllowWhileIdle` requires the `SCHEDULE_EXACT_ALARM` or `USE_EXACT_ALARM` permission on Android 12+. This is declared in `AndroidManifest.xml`. Some OEM battery savers may still suppress notifications — this is a platform limitation.

---

## 8. Theme System Deep Dive

### How the gradient background works

```
MaterialApp.builder:
  Container(decoration: BoxDecoration(gradient: AppTheme.bgGradient))
    └── child (the entire app widget tree)
         └── Scaffold(backgroundColor: Colors.transparent)
              └── ... all screens
```

Every `Scaffold` in the app sets `backgroundColor: Colors.transparent`. This allows the single gradient `Container` at the `MaterialApp` level to show through the entire navigation stack. Adding a new screen with a non-transparent Scaffold will block the gradient — use `GradientScaffold` or set `backgroundColor: Colors.transparent` explicitly.

### The `withAlphaPercent` extension

All opacity work uses `withAlphaPercent(double)` where 0.0 is fully transparent and 1.0 is fully opaque. Never use Flutter's deprecated `withOpacity()`.

---

## 9. How to Contribute

### Getting started

```bash
git clone <repo-url>
cd Eat_Your_Meal
flutter pub get
flutter run
```

Minimum Flutter SDK: **3.x** with Dart **≥ 3.2.0**.

### Code conventions

- All colours must come from `AppTheme`. Never hardcode hex values.
- All opacity must use `.withAlphaPercent()`. Never use `.withOpacity()`.
- Screens must not call `StorageService` or `NotificationService` directly — always go through `AppState`.
- New models must implement `toMap()`, `fromMap()`, `toJson()`, `fromJson()`. Store `DateTime` as ISO 8601 strings.
- New repeat modes added to `RepeatMode` must also be handled in:
  - `RepeatModeLabel.label` and `shortLabel`
  - `NotificationService._daysForRepeat()`
  - `AddReminderScreen._repeatHint()`

### Adding a new mood emoji

Open `lib/models/food_log_entry.dart` and append to `kMoodEmojis`:

```dart
const List<String> kMoodEmojis = ['😊', '😋', '🤩', '😐', '😴', '🤢', '💪', /* add here */];
```

### Adding a new meal emoji to the picker

Open `lib/widgets/emoji_picker.dart` and append to `kMealEmojis`.

### Adding a new screen

1. Create `lib/screens/my_screen.dart`.
2. Use `GradientScaffold` as the root widget.
3. Use `GlassCard` for content containers.
4. Navigate via `Navigator.push(context, MaterialPageRoute(builder: (_) => MyScreen()))`.
5. Access state via `context.watch<AppState>()` (for reactive reads) or `context.read<AppState>()` (for one-time reads inside callbacks).

### Writing tests

Mock `SharedPreferences` and the notification plugin:

```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

For notification tests, mock `FlutterLocalNotificationsPlugin` using `mockito` or `mocktail`.

### Changing the storage schema

1. Bump the key suffix in `StorageService` (e.g. `reminders_v2` → `reminders_v3`).
2. Write a migration function that reads from the old key, transforms the data, and writes to the new key.
3. Call the migration in `AppState.init()` before the normal load.

### Platform-specific setup

**Android** — `AndroidManifest.xml` must declare:
- `RECEIVE_BOOT_COMPLETED` — rescheduling notifications after reboot (not yet implemented; a future contribution opportunity).
- `SCHEDULE_EXACT_ALARM` — required for exact alarms on Android 12+.

**iOS / macOS** — notification permissions are requested at runtime via `NotificationService.requestPermission()`. No additional setup needed for basic notifications.

---

## 10. Known Limitations & Future Work

| Area | Limitation | Suggested fix |
|---|---|---|
| Notification IDs | Hash collision possible between two reminders | Use a monotonic counter or a stronger hash |
| Timezone detection | Incomplete offset-to-IANA map | Use the `flutter_timezone` package for reliable detection |
| Boot persistence | Notifications are not rescheduled after device reboot | Add a `BootReceiver` on Android |
| Notification tap | Tapping a notification does not open the app to the correct screen | Implement `onDidReceiveNotificationResponse` callback |
| Tests | Widget test currently broken (SharedPreferences not mocked) | Add proper test setup with `SharedPreferences.setMockInitialValues` |
| Data export | No way to export the food diary | Add CSV or JSON export from `AppState.foodLogs` |
| Notification ID formula | Day-based ID scheme limits to 8 slots per reminder (0–7) | Move to a cleaner ID strategy if new repeat modes are added |
| Dark mode | Only a light theme is defined | Add `AppTheme.dark` and a `ThemeMode` toggle |

---

*This documentation was generated from the source code of `Eat_Your_Meal v1.0.0+1`.*
