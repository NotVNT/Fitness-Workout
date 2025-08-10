import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutReminderService {
  static const _key = 'workout_reminder_time';

  /// Save reminder time (hour:minute in 24h)
  static Future<void> save(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode({'h': hour, 'm': minute}));
  }

  /// Load reminder time. Returns null if not set.
  static Future<({int h, int m})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null) return null;

    try {
      final map = json.decode(str) as Map<String, dynamic>;
      final h = map['h'];
      final m = map['m'];

      // Handle missing fields gracefully
      if (h == null && m == null) return null;

      return (
        h: h != null ? (h as num).toInt() : 0,
        m: m != null ? (m as num).toInt() : 0,
      );
    } catch (e) {
      // Return null if JSON parsing fails
      return null;
    }
  }
}
