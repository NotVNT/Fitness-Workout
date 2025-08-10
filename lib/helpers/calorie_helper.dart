import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/workout_service.dart';

class CalorieHelper {
  // Tính tổng kcal đốt cháy hôm nay từ workout đã hoàn thành
  static Future<int> loadTodayBurnedCalories(context) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return 0;
    final items = await WorkoutService.getUserWorkouts(user.id);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    int total = 0;
    for (final w in items) {
      final t = w.endTime;
      if (w.status == 'completed' && t != null && !t.isBefore(start) && t.isBefore(end)) {
        total += (w.caloriesBurned ?? 0);
      }
    }
    return total;
  }
}

