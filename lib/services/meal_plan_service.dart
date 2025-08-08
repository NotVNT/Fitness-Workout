import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import 'meal_recommendation_service.dart';

class MealPlanService {
  static const String _mealPlanKey = 'meal_plan_data';
  static const String _selectedDateKey = 'selected_date';

  // Lưu kế hoạch bữa ăn cho một ngày cụ thể
  static Future<void> saveDailyMealPlan(DateTime date, DailyMealPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDateKey(date);
    final planJson = plan.toJson();
    await prefs.setString('${_mealPlanKey}_$dateKey', json.encode(planJson));
  }

  // Lấy kế hoạch bữa ăn cho một ngày cụ thể
  static Future<DailyMealPlan?> getDailyMealPlan(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDateKey(date);
    final planString = prefs.getString('${_mealPlanKey}_$dateKey');
    
    if (planString != null) {
      final planJson = json.decode(planString);
      return DailyMealPlan.fromJson(planJson);
    }
    return null;
  }

  // Thêm món ăn vào kế hoạch
  static Future<void> addMealToPlan(DateTime date, MealModel meal) async {
    DailyMealPlan? existingPlan = await getDailyMealPlan(date);
    
    if (existingPlan == null) {
      // Tạo kế hoạch mới
      existingPlan = DailyMealPlan(
        breakfast: meal.category == MealCategory.breakfast ? [meal] : [],
        lunch: meal.category == MealCategory.lunch ? [meal] : [],
        snack: meal.category == MealCategory.snack ? [meal] : [],
        dinner: meal.category == MealCategory.dinner ? [meal] : [],
      );
    } else {
      // Thêm vào kế hoạch hiện có
      switch (meal.category) {
        case MealCategory.breakfast:
          existingPlan = DailyMealPlan(
            breakfast: [...existingPlan.breakfast, meal],
            lunch: existingPlan.lunch,
            snack: existingPlan.snack,
            dinner: existingPlan.dinner,
          );
          break;
        case MealCategory.lunch:
          existingPlan = DailyMealPlan(
            breakfast: existingPlan.breakfast,
            lunch: [...existingPlan.lunch, meal],
            snack: existingPlan.snack,
            dinner: existingPlan.dinner,
          );
          break;
        case MealCategory.snack:
          existingPlan = DailyMealPlan(
            breakfast: existingPlan.breakfast,
            lunch: existingPlan.lunch,
            snack: [...existingPlan.snack, meal],
            dinner: existingPlan.dinner,
          );
          break;
        case MealCategory.dinner:
          existingPlan = DailyMealPlan(
            breakfast: existingPlan.breakfast,
            lunch: existingPlan.lunch,
            snack: existingPlan.snack,
            dinner: [...existingPlan.dinner, meal],
          );
          break;
        case MealCategory.dessert:
          // Tráng miệng có thể thêm vào snack
          existingPlan = DailyMealPlan(
            breakfast: existingPlan.breakfast,
            lunch: existingPlan.lunch,
            snack: [...existingPlan.snack, meal],
            dinner: existingPlan.dinner,
          );
          break;
      }
    }
    
    await saveDailyMealPlan(date, existingPlan);
  }

  // Xóa món ăn khỏi kế hoạch
  static Future<void> removeMealFromPlan(DateTime date, String mealId) async {
    DailyMealPlan? existingPlan = await getDailyMealPlan(date);
    
    if (existingPlan != null) {
      final updatedPlan = DailyMealPlan(
        breakfast: existingPlan.breakfast.where((meal) => meal.id != mealId).toList(),
        lunch: existingPlan.lunch.where((meal) => meal.id != mealId).toList(),
        snack: existingPlan.snack.where((meal) => meal.id != mealId).toList(),
        dinner: existingPlan.dinner.where((meal) => meal.id != mealId).toList(),
      );
      
      await saveDailyMealPlan(date, updatedPlan);
    }
  }

  // Tạo kế hoạch bữa ăn tự động dựa trên BMI
  static Future<DailyMealPlan> generateAutomaticMealPlan(UserModel user) async {
    final recommendations = MealRecommendationService.getRecommendations(
      user: user,
      category: MealCategory.breakfast,
      limit: 2,
    );
    
    final lunchRecommendations = MealRecommendationService.getRecommendations(
      user: user,
      category: MealCategory.lunch,
      limit: 2,
    );
    
    final snackRecommendations = MealRecommendationService.getRecommendations(
      user: user,
      category: MealCategory.snack,
      limit: 1,
    );
    
    final dinnerRecommendations = MealRecommendationService.getRecommendations(
      user: user,
      category: MealCategory.dinner,
      limit: 2,
    );

    return DailyMealPlan(
      breakfast: recommendations,
      lunch: lunchRecommendations,
      snack: snackRecommendations,
      dinner: dinnerRecommendations,
    );
  }

  // Lưu ngày được chọn
  static Future<void> saveSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedDateKey, date.toIso8601String());
  }

  // Lấy ngày được chọn
  static Future<DateTime> getSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_selectedDateKey);
    
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return DateTime.now();
  }

  // Lấy tổng dinh dưỡng trong ngày
  static NutritionSummary getDailyNutritionSummary(DailyMealPlan plan) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (final meal in plan.allMeals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
      totalFiber += meal.fiber;
    }

    return NutritionSummary(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
    );
  }

  // Lấy kế hoạch bữa ăn cho tuần
  static Future<Map<DateTime, DailyMealPlan>> getWeeklyMealPlan(DateTime startDate) async {
    Map<DateTime, DailyMealPlan> weeklyPlan = {};
    
    for (int i = 0; i < 7; i++) {
      DateTime date = startDate.add(Duration(days: i));
      DailyMealPlan? plan = await getDailyMealPlan(date);
      if (plan != null) {
        weeklyPlan[date] = plan;
      }
    }
    
    return weeklyPlan;
  }

  // Format date key for storage
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Xóa tất cả kế hoạch bữa ăn
  static Future<void> clearAllMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_mealPlanKey));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Sao chép kế hoạch từ ngày này sang ngày khác
  static Future<void> copyMealPlan(DateTime fromDate, DateTime toDate) async {
    final plan = await getDailyMealPlan(fromDate);
    if (plan != null) {
      await saveDailyMealPlan(toDate, plan);
    }
  }
}
