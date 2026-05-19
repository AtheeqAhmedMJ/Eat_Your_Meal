import 'package:flutter/foundation.dart';
import '../models/meal_reminder.dart';
import '../models/food_log_entry.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();
  List<MealReminder> reminders = [];
  List<FoodLogEntry> foodLogs = [];
  bool loading = true;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

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

  List<MealReminder> _defaultReminders() => [
        MealReminder(
          id: newId(),
          name: 'Break fast',
          emoji: '🥐',
          timeStr: '08:30',
          repeat: RepeatMode.daily,
          enabled: true,
          createdAt: DateTime.now(),
        ),
        MealReminder(
          id: newId(),
          name: 'Lunch',
          emoji: '🥗',
          timeStr: '13:20',
          repeat: RepeatMode.daily,
          enabled: true,
          createdAt: DateTime.now(),
        ),
        MealReminder(
          id: newId(),
          name: 'Snacks',
          emoji: '🍎',
          timeStr: '17:30',
          repeat: RepeatMode.daily,
          enabled: true,
          createdAt: DateTime.now(),
        ),
        MealReminder(
          id: newId(),
          name: 'Dinner',
          emoji: '🍽️',
          timeStr: '20:30',
          repeat: RepeatMode.daily,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      ];

  Future<void> addReminder(MealReminder r) async {
    reminders.add(r);
    await StorageService.instance.saveReminders(reminders);
    await NotificationService.instance.scheduleReminder(r);
    _notify();
  }

  Future<void> updateReminder(MealReminder updated) async {
    final idx = reminders.indexWhere((r) => r.id == updated.id);
    if (idx == -1) return;
    reminders[idx] = updated;
    await StorageService.instance.saveReminders(reminders);
    await NotificationService.instance.scheduleReminder(updated);
    _notify();
  }

  Future<void> toggleReminder(String id) async {
    final idx = reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    reminders[idx] = reminders[idx].copyWith(enabled: !reminders[idx].enabled);
    await StorageService.instance.saveReminders(reminders);
    await NotificationService.instance.scheduleReminder(reminders[idx]);
    _notify();
  }

  Future<void> deleteReminder(String id) async {
    await NotificationService.instance.cancelReminder(id);
    reminders.removeWhere((r) => r.id == id);
    await StorageService.instance.saveReminders(reminders);
    _notify();
  }

  Future<void> addLog(FoodLogEntry e) async {
    foodLogs.add(e);
    await StorageService.instance.saveLogs(foodLogs);
    _notify();
  }

  Future<void> updateLog(FoodLogEntry updated) async {
    final idx = foodLogs.indexWhere((l) => l.id == updated.id);
    if (idx == -1) return;
    foodLogs[idx] = updated;
    await StorageService.instance.saveLogs(foodLogs);
    _notify();
  }

  Future<void> deleteLog(String id) async {
    foodLogs.removeWhere((l) => l.id == id);
    await StorageService.instance.saveLogs(foodLogs);
    _notify();
  }

  List<FoodLogEntry> logsForDate(DateTime date) => foodLogs
      .where((l) =>
          l.date.year == date.year &&
          l.date.month == date.month &&
          l.date.day == date.day)
      .toList()
    ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

  String newId() => _uuid.v4();
}
