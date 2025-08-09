import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_schedule.dart';

class SleepScheduleService {
  static const String _keyPrefix = 'sleep_schedule_';

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Future<void> save(DateTime date, SleepSchedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix${_dateKey(date)}', schedule.toJson());
  }

  static Future<SleepSchedule?> load(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('$_keyPrefix${_dateKey(date)}');
    if (str == null) return null;
    return SleepSchedule.fromJson(str);
  }

  static Future<void> delete(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix${_dateKey(date)}');
  }
}

