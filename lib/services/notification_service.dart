import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/meal_reminder.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(_detectTzName()));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: (_) {});
    _initialized = true;
  }

  String _detectTzName() {
    try {
      final name = DateTime.now().timeZoneName;
      tz.getLocation(name); // throws if not found
      return name;
    } catch (_) {
      final h = DateTime.now().timeZoneOffset.inMinutes;
      const map = {
        330: 'Asia/Kolkata',
        0: 'Europe/London',
        60: 'Europe/Paris',
        120: 'Europe/Athens',
        -300: 'America/New_York',
        -360: 'America/Chicago',
        -420: 'America/Denver',
        -480: 'America/Los_Angeles',
        480: 'Asia/Shanghai',
        540: 'Asia/Tokyo',
        600: 'Australia/Sydney',
      };
      return map[h] ?? 'UTC';
    }
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return (await android.requestNotificationsPermission()) ?? false;
    }
    if (ios != null) {
      return (await ios.requestPermissions(
              alert: true, badge: true, sound: true)) ??
          false;
    }
    if (macos != null) {
      return (await macos.requestPermissions(
              alert: true, badge: true, sound: true)) ??
          false;
    }
    return true;
  }

  Future<void> scheduleReminder(MealReminder meal) async {
    await cancelReminder(meal.id);
    if (!meal.enabled) return;

    final parts = meal.timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'meal_reminders',
        'Meal Reminders',
        channelDescription: 'Daily meal reminders from Eat Your Meal',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          "Time for your ${meal.name}! Open Eat Your Meal to log what you ate. 🍽️",
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    for (final day in _daysForRepeat(meal.repeat)) {
      final id = _notifId(meal.id, day);
      final scheduledDate = _nextOccurrence(hour, minute, day);
      try {
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
      } catch (e) {
        debugPrint('scheduleReminder error id=$id: $e');
      }
    }
  }

  Future<void> cancelReminder(String mealId) async {
    for (int d = 0; d <= 7; d++) {
      await _plugin.cancel(_notifId(mealId, d));
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  List<int> _daysForRepeat(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.daily:
        return [1, 2, 3, 4, 5, 6, 7];
      case RepeatMode.weekdays:
        return [1, 2, 3, 4, 5];
      case RepeatMode.weekends:
        return [6, 7];
      case RepeatMode.once:
        return [0];
    }
  }

  int _notifId(String mealId, int day) =>
      (mealId.hashCode.abs() * 10 + day) % 2147483647;

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
      if (++tries > 14) break;
    }
    return c;
  }
}
