import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import '../services/meal_plan_service.dart';

class MealPlanProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DailyMealPlan? _currentPlan;
  bool _isLoading = false;
  String? _error;

  // Getters
  DateTime get selectedDate => _selectedDate;
  DailyMealPlan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get meals by category
  List<MealModel> get breakfastMeals => _currentPlan?.breakfast ?? [];
  List<MealModel> get lunchMeals => _currentPlan?.lunch ?? [];
  List<MealModel> get snackMeals => _currentPlan?.snack ?? [];
  List<MealModel> get dinnerMeals => _currentPlan?.dinner ?? [];

  // Get nutrition summary
  NutritionSummary? get dailyNutrition {
    if (_currentPlan != null) {
      return MealPlanService.getDailyNutritionSummary(_currentPlan!);
    }
    return null;
  }

  // Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDate = await MealPlanService.getSelectedDate();
      await loadMealPlan(_selectedDate);
    } catch (e) {
      _error = 'Lỗi khởi tạo: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load meal plan for specific date
  Future<void> loadMealPlan(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPlan = await MealPlanService.getDailyMealPlan(date);
      _selectedDate = date;
      await MealPlanService.saveSelectedDate(date);
    } catch (e) {
      _error = 'Lỗi tải kế hoạch: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change selected date
  Future<void> changeDate(DateTime newDate) async {
    if (newDate.day != _selectedDate.day ||
        newDate.month != _selectedDate.month ||
        newDate.year != _selectedDate.year) {
      await loadMealPlan(newDate);
    }
  }

  // Add meal to plan
  Future<void> addMeal(MealModel meal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await MealPlanService.addMealToPlan(_selectedDate, meal);
      await loadMealPlan(_selectedDate); // Reload to get updated plan
    } catch (e) {
      _error = 'Lỗi thêm món ăn: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove meal from plan
  Future<void> removeMeal(String mealId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await MealPlanService.removeMealFromPlan(_selectedDate, mealId);
      await loadMealPlan(_selectedDate); // Reload to get updated plan
    } catch (e) {
      _error = 'Lỗi xóa món ăn: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate automatic meal plan
  Future<void> generateAutomaticPlan(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final automaticPlan = await MealPlanService.generateAutomaticMealPlan(user);
      await MealPlanService.saveDailyMealPlan(_selectedDate, automaticPlan);
      await loadMealPlan(_selectedDate); // Reload to get updated plan
    } catch (e) {
      _error = 'Lỗi tạo kế hoạch tự động: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current plan
  Future<void> clearPlan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final emptyPlan = DailyMealPlan(
        breakfast: [],
        lunch: [],
        snack: [],
        dinner: [],
      );
      await MealPlanService.saveDailyMealPlan(_selectedDate, emptyPlan);
      await loadMealPlan(_selectedDate);
    } catch (e) {
      _error = 'Lỗi xóa kế hoạch: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Copy plan from another date
  Future<void> copyPlanFromDate(DateTime fromDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await MealPlanService.copyMealPlan(fromDate, _selectedDate);
      await loadMealPlan(_selectedDate);
    } catch (e) {
      _error = 'Lỗi sao chép kế hoạch: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get meal count by category
  int getMealCount(MealCategory category) {
    if (_currentPlan == null) return 0;
    
    switch (category) {
      case MealCategory.breakfast:
        return _currentPlan!.breakfast.length;
      case MealCategory.lunch:
        return _currentPlan!.lunch.length;
      case MealCategory.snack:
        return _currentPlan!.snack.length;
      case MealCategory.dinner:
        return _currentPlan!.dinner.length;
      case MealCategory.dessert:
        return _currentPlan!.snack.where((meal) => meal.category == MealCategory.dessert).length;
    }
  }

  // Get calories by category
  double getCategoricalCalories(MealCategory category) {
    if (_currentPlan == null) return 0;
    
    List<MealModel> meals = [];
    switch (category) {
      case MealCategory.breakfast:
        meals = _currentPlan!.breakfast;
        break;
      case MealCategory.lunch:
        meals = _currentPlan!.lunch;
        break;
      case MealCategory.snack:
        meals = _currentPlan!.snack;
        break;
      case MealCategory.dinner:
        meals = _currentPlan!.dinner;
        break;
      case MealCategory.dessert:
        meals = _currentPlan!.snack.where((meal) => meal.category == MealCategory.dessert).toList();
        break;
    }
    
    return meals.fold(0.0, (sum, meal) => sum + meal.calories);
  }

  // Check if plan has any meals
  bool get hasMeals {
    return _currentPlan != null && _currentPlan!.allMeals.isNotEmpty;
  }

  // Get total meals count
  int get totalMealsCount {
    return _currentPlan?.allMeals.length ?? 0;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Go to next day
  Future<void> nextDay() async {
    final nextDate = _selectedDate.add(const Duration(days: 1));
    await changeDate(nextDate);
  }

  // Go to previous day
  Future<void> previousDay() async {
    final previousDate = _selectedDate.subtract(const Duration(days: 1));
    await changeDate(previousDate);
  }

  // Go to today
  Future<void> goToToday() async {
    final today = DateTime.now();
    await changeDate(DateTime(today.year, today.month, today.day));
  }
}
