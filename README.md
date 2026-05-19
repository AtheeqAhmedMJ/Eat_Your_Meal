##Eat Your Meal

A Flutter meal reminder & food diary app with glassmorphism UI.

---

## Features

- **Smart Reminders** — Set meal reminders that fire daily, weekdays, weekends, or once. Notifications keep ringing every day at the scheduled time until you change or disable them.
- **Food Diary** — Log what you actually ate each day with optional notes and mood tracking.
- **Glassmorphism UI** — Light, airy glass-effect cards with a soft sky-to-lavender gradient background.
- **Quick Fill** — When logging a meal, tap a reminder chip to pre-fill the name and emoji.
- **Slide Actions** — Swipe left on any card to edit or delete.
- **Toggle Reminders** — Pause/resume any reminder without deleting it.
- **Persisted Storage** — Everything saved locally via SharedPreferences, survives app restarts.

---

## Quick Start

### Prerequisites
- Flutter SDK ≥ 3.2.0
- Dart ≥ 3.2.0
- Android SDK or Xcode (for iOS)

### Run

```bash
cd Eat_Your_Meal
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

---

## Project Structure

```
lib/
├── main.dart                  # Entry point, provider setup
├── models/
│   ├── meal_reminder.dart     # Reminder model + RepeatMode enum
│   └── food_log_entry.dart    # Food diary entry model
├── services/
│   ├── app_state.dart         # ChangeNotifier app state
│   ├── notification_service.dart  # Scheduling, timezone handling
│   └── storage_service.dart   # SharedPreferences persistence
├── screens/
│   ├── home_screen.dart       # Tab navigation shell
│   ├── reminders_tab.dart     # Reminders list tab
│   ├── add_reminder_screen.dart  # Add/edit reminder form
│   ├── diary_tab.dart         # Food diary with date strip
│   └── add_log_screen.dart    # Log a meal form
├── widgets/
│   ├── glass_card.dart        # Reusable glass-effect card
│   ├── gradient_scaffold.dart # Background gradient wrapper
│   ├── reminder_tile.dart     # Slidable reminder list item
│   ├── food_log_tile.dart     # Slidable food log list item
│   └── emoji_picker.dart      # Bottom sheet emoji selector
└── utils/
    └── app_theme.dart         # Colors, gradients, ThemeData
```

---

## How Repeating Notifications Work

When you set a reminder with **Daily** repeat, the app schedules 7 separate `zonedSchedule` notifications (one per weekday slot) each using `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`. This causes the OS to **automatically re-fire the notification every week on the same day at the same time** — no background service needed.

- **Daily** → 7 notifications (Mon–Sun), each repeating weekly → effectively fires every day
- **Weekdays** → 5 notifications (Mon–Fri), each repeating weekly
- **Weekends** → 2 notifications (Sat–Sun), each repeating weekly
- **Once** → 1 notification at the next occurrence of that time, no repeat

Changing or disabling a reminder cancels all its existing notifications and reschedules fresh ones.

---

## Android Permissions

The app requests:
- `POST_NOTIFICATIONS` (Android 13+)
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` (for precise timing)
- `RECEIVE_BOOT_COMPLETED` (reschedule after device reboot)

---

## Packages Used

| Package | Purpose |
|---|---|
| `flutter_local_notifications` | Local push notifications |
| `timezone` | Correct timezone-aware scheduling |
| `shared_preferences` | Local persistence |
| `provider` | State management |
| `flutter_slidable` | Swipe-to-edit/delete on tiles |
| `flutter_animate` | Entry animations |
| `google_fonts` | Playfair Display + Nunito Sans |
| `iconsax` | Icon pack |
| `intl` | Date/time formatting |
| `uuid` | Unique IDs for reminders/logs |
| `permission_handler` | Runtime permission requests |
