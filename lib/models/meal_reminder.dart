import 'dart:convert';

class MealReminder {
  final String id;
  String name;
  String emoji;
  String timeStr; // "HH:mm" 24h
  RepeatMode repeat;
  bool enabled;
  final DateTime createdAt;

  MealReminder({
    required this.id,
    required this.name,
    required this.emoji,
    required this.timeStr,
    required this.repeat,
    this.enabled = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'timeStr': timeStr,
        'repeat': repeat.index,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MealReminder.fromMap(Map<String, dynamic> m) => MealReminder(
        id: m['id'],
        name: m['name'],
        emoji: m['emoji'],
        timeStr: m['timeStr'],
        repeat: RepeatMode.values[m['repeat'] ?? 0],
        enabled: m['enabled'] ?? true,
        createdAt: DateTime.parse(m['createdAt']),
      );

  String toJson() => jsonEncode(toMap());
  factory MealReminder.fromJson(String src) =>
      MealReminder.fromMap(jsonDecode(src));

  MealReminder copyWith({
    String? name,
    String? emoji,
    String? timeStr,
    RepeatMode? repeat,
    bool? enabled,
  }) =>
      MealReminder(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        timeStr: timeStr ?? this.timeStr,
        repeat: repeat ?? this.repeat,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt,
      );
}

enum RepeatMode { daily, weekdays, weekends, once }

extension RepeatModeLabel on RepeatMode {
  String get label {
    switch (this) {
      case RepeatMode.daily:
        return 'Every Day';
      case RepeatMode.weekdays:
        return 'Weekdays';
      case RepeatMode.weekends:
        return 'Weekends';
      case RepeatMode.once:
        return 'Once';
    }
  }

  String get shortLabel {
    switch (this) {
      case RepeatMode.daily:
        return 'Daily';
      case RepeatMode.weekdays:
        return 'Mon–Fri';
      case RepeatMode.weekends:
        return 'Sat–Sun';
      case RepeatMode.once:
        return 'Once';
    }
  }
}
