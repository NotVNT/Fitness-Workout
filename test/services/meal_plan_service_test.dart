import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness/services/meal_plan_service.dart';
import 'package:fitness/models/meal_model.dart';
import 'package:fitness/models/user_model.dart';

void main() {
  group('MealPlanService Tests', () {
    late DateTime testDate;
    late MealModel testBreakfastMeal;
    late MealModel testLunchMeal;
    late MealModel testSnackMeal;
    late MealModel testDinnerMeal;
    late MealModel testDessertMeal;
    late DailyMealPlan testPlan;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      
      testDate = DateTime(2024, 1, 15);
      
      testBreakfastMeal = MealModel(
        id: 'breakfast_1',
        name: 'Oatmeal',
        nameEn: 'Oatmeal',
        category: MealCategory.breakfast,
        calories: 300.0,
        protein: 10.0,
        carbs: 50.0,
        fat: 8.0,
        fiber: 5.0,
        preparationTime: 10,
        difficulty: MealDifficulty.easy,
        ingredients: ['Oats', 'Milk'],
        instructions: ['Cook oats', 'Add milk'],
        isHealthy: true,
        isVegetarian: true,
        tags: ['healthy', 'breakfast'],
      );

      testLunchMeal = MealModel(
        id: 'lunch_1',
        name: 'Chicken Salad',
        nameEn: 'Chicken Salad',
        category: MealCategory.lunch,
        calories: 400.0,
        protein: 30.0,
        carbs: 20.0,
        fat: 15.0,
        fiber: 8.0,
        preparationTime: 20,
        difficulty: MealDifficulty.medium,
        ingredients: ['Chicken', 'Lettuce', 'Tomato'],
        instructions: ['Grill chicken', 'Mix salad'],
        isHealthy: true,
        isVegetarian: false,
        tags: ['protein', 'lunch'],
      );

      testSnackMeal = MealModel(
        id: 'snack_1',
        name: 'Apple',
        nameEn: 'Apple',
        category: MealCategory.snack,
        calories: 100.0,
        protein: 1.0,
        carbs: 25.0,
        fat: 0.5,
        fiber: 4.0,
        preparationTime: 0,
        difficulty: MealDifficulty.easy,
        ingredients: ['Apple'],
        instructions: ['Wash and eat'],
        isHealthy: true,
        isVegetarian: true,
        tags: ['fruit', 'snack'],
      );

      testDinnerMeal = MealModel(
        id: 'dinner_1',
        name: 'Grilled Fish',
        nameEn: 'Grilled Fish',
        category: MealCategory.dinner,
        calories: 350.0,
        protein: 40.0,
        carbs: 10.0,
        fat: 12.0,
        fiber: 2.0,
        preparationTime: 30,
        difficulty: MealDifficulty.medium,
        ingredients: ['Fish', 'Vegetables'],
        instructions: ['Grill fish', 'Steam vegetables'],
        isHealthy: true,
        isVegetarian: false,
        tags: ['protein', 'dinner'],
      );

      testDessertMeal = MealModel(
        id: 'dessert_1',
        name: 'Fruit Yogurt',
        nameEn: 'Fruit Yogurt',
        category: MealCategory.dessert,
        calories: 150.0,
        protein: 8.0,
        carbs: 20.0,
        fat: 4.0,
        fiber: 2.0,
        preparationTime: 5,
        difficulty: MealDifficulty.easy,
        ingredients: ['Yogurt', 'Berries'],
        instructions: ['Mix yogurt with berries'],
        isHealthy: true,
        isVegetarian: true,
        tags: ['dessert', 'healthy'],
      );

      testPlan = DailyMealPlan(
        breakfast: [testBreakfastMeal],
        lunch: [testLunchMeal],
        snack: [testSnackMeal],
        dinner: [testDinnerMeal],
      );
    });

    group('Save and Load Daily Meal Plan Tests', () {
      test('should save and load daily meal plan correctly', () async {
        // Act
        await MealPlanService.saveDailyMealPlan(testDate, testPlan);
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan, isNotNull);
        expect(loadedPlan!.breakfast.length, equals(1));
        expect(loadedPlan.lunch.length, equals(1));
        expect(loadedPlan.snack.length, equals(1));
        expect(loadedPlan.dinner.length, equals(1));
        
        expect(loadedPlan.breakfast[0].id, equals('breakfast_1'));
        expect(loadedPlan.lunch[0].id, equals('lunch_1'));
        expect(loadedPlan.snack[0].id, equals('snack_1'));
        expect(loadedPlan.dinner[0].id, equals('dinner_1'));
      });

      test('should return null when no meal plan exists for date', () async {
        // Act
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan, isNull);
      });

      test('should handle different dates correctly', () async {
        // Arrange
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        
        final plan1 = DailyMealPlan(
          breakfast: [testBreakfastMeal],
          lunch: [],
          snack: [],
          dinner: [],
        );
        
        final plan2 = DailyMealPlan(
          breakfast: [],
          lunch: [testLunchMeal],
          snack: [],
          dinner: [],
        );

        // Act
        await MealPlanService.saveDailyMealPlan(date1, plan1);
        await MealPlanService.saveDailyMealPlan(date2, plan2);

        final loadedPlan1 = await MealPlanService.getDailyMealPlan(date1);
        final loadedPlan2 = await MealPlanService.getDailyMealPlan(date2);

        // Assert
        expect(loadedPlan1!.breakfast.length, equals(1));
        expect(loadedPlan1.lunch.length, equals(0));
        
        expect(loadedPlan2!.breakfast.length, equals(0));
        expect(loadedPlan2.lunch.length, equals(1));
      });
    });

    group('Add Meal to Plan Tests', () {
      test('should create new plan when adding meal to empty date', () async {
        // Act
        await MealPlanService.addMealToPlan(testDate, testBreakfastMeal);
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan, isNotNull);
        expect(loadedPlan!.breakfast.length, equals(1));
        expect(loadedPlan.lunch.length, equals(0));
        expect(loadedPlan.snack.length, equals(0));
        expect(loadedPlan.dinner.length, equals(0));
        expect(loadedPlan.breakfast[0].id, equals('breakfast_1'));
      });

      test('should add breakfast meal to existing plan', () async {
        // Arrange
        await MealPlanService.saveDailyMealPlan(testDate, testPlan);
        
        final newBreakfastMeal = MealModel(
          id: 'breakfast_2',
          name: 'Pancakes',
          nameEn: 'Pancakes',
          category: MealCategory.breakfast,
          calories: 250.0,
          protein: 8.0,
          carbs: 40.0,
          fat: 6.0,
          fiber: 2.0,
          preparationTime: 15,
          difficulty: MealDifficulty.medium,
          ingredients: ['Flour', 'Eggs'],
          instructions: ['Mix and cook'],
          isHealthy: false,
          isVegetarian: true,
          tags: ['breakfast'],
        );

        // Act
        await MealPlanService.addMealToPlan(testDate, newBreakfastMeal);
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan!.breakfast.length, equals(2));
        expect(loadedPlan.breakfast[0].id, equals('breakfast_1'));
        expect(loadedPlan.breakfast[1].id, equals('breakfast_2'));
        expect(loadedPlan.lunch.length, equals(1)); // Should remain unchanged
      });

      test('should add lunch meal to existing plan', () async {
        // Arrange
        await MealPlanService.saveDailyMealPlan(testDate, testPlan);
        
        final newLunchMeal = MealModel(
          id: 'lunch_2',
          name: 'Sandwich',
          nameEn: 'Sandwich',
          category: MealCategory.lunch,
          calories: 300.0,
          protein: 15.0,
          carbs: 35.0,
          fat: 10.0,
          fiber: 3.0,
          preparationTime: 10,
          difficulty: MealDifficulty.easy,
          ingredients: ['Bread', 'Ham'],
          instructions: ['Assemble sandwich'],
          isHealthy: true,
          isVegetarian: false,
          tags: ['lunch', 'quick'],
        );

        // Act
        await MealPlanService.addMealToPlan(testDate, newLunchMeal);
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan!.lunch.length, equals(2));
        expect(loadedPlan.lunch[0].id, equals('lunch_1'));
        expect(loadedPlan.lunch[1].id, equals('lunch_2'));
      });

      test('should add snack meal to existing plan', () async {
        // Arrange
        await MealPlanService.saveDailyMealPlan(testDate, testPlan);
        
        final newSnackMeal = MealModel(
          id: 'snack_2',
          name: 'Nuts',
          nameEn: 'Nuts',
          category: MealCategory.snack,
          calories: 200.0,
          protein: 6.0,
          carbs: 8.0,
          fat: 16.0,
          fiber: 3.0,
          preparationTime: 0,
          difficulty: MealDifficulty.easy,
          ingredients: ['Mixed nuts'],
          instructions: ['Eat'],
          isHealthy: true,
          isVegetarian: true,
          tags: ['snack', 'protein'],
        );

        // Act
        await MealPlanService.addMealToPlan(testDate, newSnackMeal);
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan!.snack.length, equals(2));
        expect(loadedPlan.snack[0].id, equals('snack_1'));
        expect(loadedPlan.snack[1].id, equals('snack_2'));
      });

      test('should add dinner meal to existing plan', () async {
        // Arrange
        await MealPlanService.saveDailyMealPlan(testDate, testPlan);
        
        final newDinnerMeal = MealModel(
          id: 'dinner_2',
          name: 'Pasta',
          nameEn: 'Pasta',
          category: MealCategory.dinner,
          calories: 450.0,
          protein: 18.0,
          carbs: 60.0,
          fat: 12.0,
          fiber: 4.0,
          preparationTime: 25,
          difficulty: MealDifficulty.medium,
          ingredients: ['Pasta', 'Sauce'],
          instructions: ['Cook pasta', 'Add sauce'],
          isHealthy: true,
          isVegetarian: true,
          tags: ['dinner', 'carbs'],
        );

        // Act
        await MealPlanService.addMealToPlan(testDate, newDinnerMeal);
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan!.dinner.length, equals(2));
        expect(loadedPlan.dinner[0].id, equals('dinner_1'));
        expect(loadedPlan.dinner[1].id, equals('dinner_2'));
      });

      test('should add dessert meal to snack category', () async {
        // Arrange
        await MealPlanService.saveDailyMealPlan(testDate, testPlan);

        // Act
        await MealPlanService.addMealToPlan(testDate, testDessertMeal);
        final loadedPlan = await MealPlanService.getDailyMealPlan(testDate);

        // Assert
        expect(loadedPlan!.snack.length, equals(2)); // Original snack + dessert
        expect(loadedPlan.snack[0].id, equals('snack_1'));
        expect(loadedPlan.snack[1].id, equals('dessert_1'));
      });
    });
  });
}
