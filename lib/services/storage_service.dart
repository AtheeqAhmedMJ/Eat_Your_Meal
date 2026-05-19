import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_reminder.dart';
import '../models/food_log_entry.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _remindersKey = 'reminders_v2';
  static const _logsKey = 'food_logs_v2';

  // ── Reminders ────────────────────────────────────────────

  Future<List<MealReminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_remindersKey) ?? [];
    return raw
        .map((s) {
          try {
            return MealReminder.fromJson(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<MealReminder>()
        .toList();
  }

  Future<void> saveReminders(List<MealReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _remindersKey, reminders.map((r) => r.toJson()).toList());
  }

  // ── Food Logs ─────────────────────────────────────────────

  Future<List<FoodLogEntry>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_logsKey) ?? [];
    return raw
        .map((s) {
          try {
            return FoodLogEntry.fromJson(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<FoodLogEntry>()
        .toList();
  }

  Future<void> saveLogs(List<FoodLogEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_logsKey, logs.map((l) => l.toJson()).toList());
  }
}
