import 'dart:convert';

class FoodLogEntry {
  final String id;
  final DateTime date;
  final String mealName;   // linked reminder name or custom
  final String emoji;
  String notes;            // what they actually ate
  String? mood;            // optional mood emoji
  final DateTime loggedAt;

  FoodLogEntry({
    required this.id,
    required this.date,
    required this.mealName,
    required this.emoji,
    required this.notes,
    this.mood,
    required this.loggedAt,
  });

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
        mealName: m['mealName'],
        emoji: m['emoji'],
        notes: m['notes'] ?? '',
        mood: m['mood'],
        loggedAt: DateTime.parse(m['loggedAt']),
      );

  String toJson() => jsonEncode(toMap());
  factory FoodLogEntry.fromJson(String src) =>
      FoodLogEntry.fromMap(jsonDecode(src));
}

const List<String> kMoodEmojis = ['😊', '😋', '🤩', '😐', '😴', '🤢', '💪'];
