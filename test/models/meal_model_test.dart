import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/meal_model.dart';

void main() {
  group('MealModel Tests', () {
    late MealModel testMeal;

    setUp(() {
      testMeal = MealModel(
        id: 'meal_1',
        name: 'Cơm gà',
        nameEn: 'Chicken Rice',
        category: MealCategory.lunch,
        calories: 450.0,
        protein: 25.0,
        carbs: 50.0,
        fat: 15.0,
        fiber: 3.0,
        preparationTime: 30,
        difficulty: MealDifficulty.medium,
        ingredients: ['Gà', 'Cơm', 'Rau'],
        instructions: ['Nấu cơm', 'Nướng gà', 'Trình bày'],
        isHealthy: true,
        isVegetarian: false,
        tags: ['protein', 'balanced'],
        imageUrl: 'https://example.com/chicken-rice.jpg',
        useNetworkImage: true,
      );
    });

    group('Constructor Tests', () {
      test('should create MealModel with all required fields', () {
        expect(testMeal.id, equals('meal_1'));
        expect(testMeal.name, equals('Cơm gà'));
        expect(testMeal.nameEn, equals('Chicken Rice'));
        expect(testMeal.category, equals(MealCategory.lunch));
        expect(testMeal.calories, equals(450.0));
        expect(testMeal.protein, equals(25.0));
        expect(testMeal.carbs, equals(50.0));
        expect(testMeal.fat, equals(15.0));
        expect(testMeal.fiber, equals(3.0));
        expect(testMeal.preparationTime, equals(30));
        expect(testMeal.difficulty, equals(MealDifficulty.medium));
        expect(testMeal.ingredients, equals(['Gà', 'Cơm', 'Rau']));
        expect(testMeal.instructions,
            equals(['Nấu cơm', 'Nướng gà', 'Trình bày']));
        expect(testMeal.isHealthy, isTrue);
        expect(testMeal.isVegetarian, isFalse);
        expect(testMeal.tags, equals(['protein', 'balanced']));
        expect(
            testMeal.imageUrl, equals('https://example.com/chicken-rice.jpg'));
        expect(testMeal.useNetworkImage, isTrue);
      });

      test('should create MealModel with default values', () {
        final meal = MealModel(
          id: 'meal_2',
          name: 'Salad',
          nameEn: 'Salad',
          category: MealCategory.snack,
          calories: 200.0,
          protein: 5.0,
          carbs: 20.0,
          fat: 10.0,
          fiber: 5.0,
          preparationTime: 10,
          difficulty: MealDifficulty.easy,
          ingredients: ['Lettuce'],
          instructions: ['Mix'],
          isHealthy: true,
          isVegetarian: true,
          tags: ['healthy'],
        );

        expect(meal.imageUrl, isNull);
        expect(meal.useNetworkImage, isFalse);
      });
    });

    group('JSON Serialization Tests', () {
      test('should convert to JSON correctly', () {
        final json = testMeal.toJson();

        expect(json['id'], equals('meal_1'));
        expect(json['name'], equals('Cơm gà'));
        expect(json['nameEn'], equals('Chicken Rice'));
        expect(json['category'], equals('MealCategory.lunch'));
        expect(json['calories'], equals(450.0));
        expect(json['protein'], equals(25.0));
        expect(json['carbs'], equals(50.0));
        expect(json['fat'], equals(15.0));
        expect(json['fiber'], equals(3.0));
        expect(json['preparationTime'], equals(30));
        expect(json['difficulty'], equals('MealDifficulty.medium'));
        expect(json['ingredients'], equals(['Gà', 'Cơm', 'Rau']));
        expect(
            json['instructions'], equals(['Nấu cơm', 'Nướng gà', 'Trình bày']));
        expect(json['isHealthy'], isTrue);
        expect(json['isVegetarian'], isFalse);
        expect(json['tags'], equals(['protein', 'balanced']));
        expect(
            json['imageUrl'], equals('https://example.com/chicken-rice.jpg'));
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'meal_1',
          'name': 'Cơm gà',
          'nameEn': 'Chicken Rice',
          'category': 'MealCategory.lunch',
          'calories': 450.0,
          'protein': 25.0,
          'carbs': 50.0,
          'fat': 15.0,
          'fiber': 3.0,
          'preparationTime': 30,
          'difficulty': 'MealDifficulty.medium',
          'ingredients': ['Gà', 'Cơm', 'Rau'],
          'instructions': ['Nấu cơm', 'Nướng gà', 'Trình bày'],
          'isHealthy': true,
          'isVegetarian': false,
          'tags': ['protein', 'balanced'],
          'imageUrl': 'https://example.com/chicken-rice.jpg',
        };

        final meal = MealModel.fromJson(json);

        expect(meal.id, equals('meal_1'));
        expect(meal.name, equals('Cơm gà'));
        expect(meal.nameEn, equals('Chicken Rice'));
        expect(meal.category, equals(MealCategory.lunch));
        expect(meal.calories, equals(450.0));
        expect(meal.protein, equals(25.0));
        expect(meal.carbs, equals(50.0));
        expect(meal.fat, equals(15.0));
        expect(meal.fiber, equals(3.0));
        expect(meal.preparationTime, equals(30));
        expect(meal.difficulty, equals(MealDifficulty.medium));
        expect(meal.ingredients, equals(['Gà', 'Cơm', 'Rau']));
        expect(meal.instructions, equals(['Nấu cơm', 'Nướng gà', 'Trình bày']));
        expect(meal.isHealthy, isTrue);
        expect(meal.isVegetarian, isFalse);
        expect(meal.tags, equals(['protein', 'balanced']));
        expect(meal.imageUrl, equals('https://example.com/chicken-rice.jpg'));
      });

      test('should handle round-trip JSON conversion', () {
        final json = testMeal.toJson();
        final recreatedMeal = MealModel.fromJson(json);

        expect(recreatedMeal.id, equals(testMeal.id));
        expect(recreatedMeal.name, equals(testMeal.name));
        expect(recreatedMeal.category, equals(testMeal.category));
        expect(recreatedMeal.calories, equals(testMeal.calories));
        expect(recreatedMeal.protein, equals(testMeal.protein));
        expect(recreatedMeal.difficulty, equals(testMeal.difficulty));
      });
    });

    group('Display Name Tests', () {
      test('should return correct category names', () {
        expect(
            MealModel(
                id: '1',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.breakfast,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.easy,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getCategoryName(),
            equals('Bữa sáng'));

        expect(
            MealModel(
                id: '2',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.lunch,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.easy,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getCategoryName(),
            equals('Bữa trưa'));

        expect(
            MealModel(
                id: '3',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.snack,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.easy,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getCategoryName(),
            equals('Bữa phụ'));

        expect(
            MealModel(
                id: '4',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.dinner,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.easy,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getCategoryName(),
            equals('Bữa tối'));

        expect(
            MealModel(
                id: '5',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.dessert,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.easy,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getCategoryName(),
            equals('Tráng miệng'));
      });

      test('should return correct difficulty names', () {
        expect(
            MealModel(
                id: '1',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.breakfast,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.easy,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getDifficultyName(),
            equals('Dễ'));

        expect(
            MealModel(
                id: '2',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.breakfast,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.medium,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getDifficultyName(),
            equals('Vừa'));

        expect(
            MealModel(
                id: '3',
                name: 'Test',
                nameEn: 'Test',
                category: MealCategory.breakfast,
                calories: 100,
                protein: 10,
                carbs: 10,
                fat: 5,
                fiber: 2,
                preparationTime: 10,
                difficulty: MealDifficulty.hard,
                ingredients: [],
                instructions: [],
                isHealthy: true,
                isVegetarian: false,
                tags: []).getDifficultyName(),
            equals('Khó'));
      });
    });

    group('Nutrition Calculation Tests', () {
      test('should calculate protein percentage correctly', () {
        // 25g protein * 4 calories/g = 100 calories
        // 100 / 450 * 100 = 22.22%
        expect(testMeal.proteinPercentage, closeTo(22.22, 0.01));
      });

      test('should calculate carbs percentage correctly', () {
        // 50g carbs * 4 calories/g = 200 calories
        // 200 / 450 * 100 = 44.44%
        expect(testMeal.carbsPercentage, closeTo(44.44, 0.01));
      });

      test('should calculate fat percentage correctly', () {
        // 15g fat * 9 calories/g = 135 calories
        // 135 / 450 * 100 = 30%
        expect(testMeal.fatPercentage, equals(30.0));
      });

      test('should identify weight loss friendly meals', () {
        final weightLossMeal = MealModel(
          id: 'wl_meal',
          name: 'Salad',
          nameEn: 'Salad',
          category: MealCategory.lunch,
          calories: 350.0, // < 400
          protein: 20.0, // 20*4/350*100 = 22.86% > 20%
          carbs: 30.0,
          fat: 10.0,
          fiber: 5.0, // > 3
          preparationTime: 15,
          difficulty: MealDifficulty.easy,
          ingredients: ['Lettuce', 'Chicken'],
          instructions: ['Mix'],
          isHealthy: true, // true
          isVegetarian: false,
          tags: ['healthy'],
        );

        expect(weightLossMeal.isWeightLossFriendly, isTrue);
      });

      test('should identify non-weight loss friendly meals', () {
        final highCalorieMeal = MealModel(
          id: 'hc_meal',
          name: 'Pizza',
          nameEn: 'Pizza',
          category: MealCategory.dinner,
          calories: 600.0, // > 400
          protein: 15.0,
          carbs: 60.0,
          fat: 25.0,
          fiber: 2.0, // < 3
          preparationTime: 45,
          difficulty: MealDifficulty.hard,
          ingredients: ['Dough', 'Cheese'],
          instructions: ['Bake'],
          isHealthy: false, // false
          isVegetarian: false,
          tags: ['comfort'],
        );

        expect(highCalorieMeal.isWeightLossFriendly, isFalse);
      });

      test('should generate nutrition summary string', () {
        final summary = testMeal.getNutritionSummary();
        expect(summary, equals('450kcal | 25g protein | 50g carbs | 15g fat'));
      });
    });
  });

  group('NutritionSummary Tests', () {
    late NutritionSummary testSummary;

    setUp(() {
      testSummary = NutritionSummary(
        calories: 2000.0,
        protein: 150.0,
        carbs: 250.0,
        fat: 67.0,
        fiber: 25.0,
      );
    });

    test('should calculate calories percentage correctly', () {
      expect(testSummary.getCaloriesPercentage(2500.0), equals(80.0));
      expect(testSummary.getCaloriesPercentage(2000.0), equals(100.0));
    });

    test('should calculate protein percentage correctly', () {
      // For 70kg person: 70 * 1.2 = 84g recommended
      // 150 / 84 * 100 = 178.57%
      expect(testSummary.getProteinPercentage(70.0), closeTo(178.57, 0.01));
    });
  });

  group('DailyMealPlan Tests', () {
    late DailyMealPlan testPlan;
    late List<MealModel> breakfastMeals;
    late List<MealModel> lunchMeals;
    late List<MealModel> snackMeals;
    late List<MealModel> dinnerMeals;

    setUp(() {
      breakfastMeals = [
        MealModel(
            id: 'b1',
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
            ingredients: ['Oats'],
            instructions: ['Cook'],
            isHealthy: true,
            isVegetarian: true,
            tags: []),
      ];

      lunchMeals = [
        MealModel(
            id: 'l1',
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
            ingredients: ['Chicken', 'Lettuce'],
            instructions: ['Mix'],
            isHealthy: true,
            isVegetarian: false,
            tags: []),
      ];

      snackMeals = [
        MealModel(
            id: 's1',
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
            instructions: ['Eat'],
            isHealthy: true,
            isVegetarian: true,
            tags: []),
      ];

      dinnerMeals = [
        MealModel(
            id: 'd1',
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
            ingredients: ['Fish'],
            instructions: ['Grill'],
            isHealthy: true,
            isVegetarian: false,
            tags: []),
      ];

      testPlan = DailyMealPlan(
        breakfast: breakfastMeals,
        lunch: lunchMeals,
        snack: snackMeals,
        dinner: dinnerMeals,
      );
    });

    test('should create DailyMealPlan correctly', () {
      expect(testPlan.breakfast, equals(breakfastMeals));
      expect(testPlan.lunch, equals(lunchMeals));
      expect(testPlan.snack, equals(snackMeals));
      expect(testPlan.dinner, equals(dinnerMeals));
    });

    test('should return all meals correctly', () {
      final allMeals = testPlan.allMeals;
      expect(allMeals.length, equals(4));
      expect(allMeals[0].id, equals('b1'));
      expect(allMeals[1].id, equals('l1'));
      expect(allMeals[2].id, equals('s1'));
      expect(allMeals[3].id, equals('d1'));
    });

    test('should calculate total nutrition correctly', () {
      final nutrition = testPlan.totalNutrition;

      // Total: 300 + 400 + 100 + 350 = 1150 calories
      expect(nutrition.calories, equals(1150.0));
      // Total: 10 + 30 + 1 + 40 = 81g protein
      expect(nutrition.protein, equals(81.0));
      // Total: 50 + 20 + 25 + 10 = 105g carbs
      expect(nutrition.carbs, equals(105.0));
      // Total: 8 + 15 + 0.5 + 12 = 35.5g fat
      expect(nutrition.fat, equals(35.5));
      // Total: 5 + 8 + 4 + 2 = 19g fiber
      expect(nutrition.fiber, equals(19.0));
    });

    test('should convert to JSON correctly', () {
      final json = testPlan.toJson();

      expect(json['breakfast'], isA<List>());
      expect(json['lunch'], isA<List>());
      expect(json['snack'], isA<List>());
      expect(json['dinner'], isA<List>());

      expect((json['breakfast'] as List).length, equals(1));
      expect((json['lunch'] as List).length, equals(1));
      expect((json['snack'] as List).length, equals(1));
      expect((json['dinner'] as List).length, equals(1));
    });

    test('should create from JSON correctly', () {
      final json = testPlan.toJson();
      final recreatedPlan = DailyMealPlan.fromJson(json);

      expect(recreatedPlan.breakfast.length, equals(1));
      expect(recreatedPlan.lunch.length, equals(1));
      expect(recreatedPlan.snack.length, equals(1));
      expect(recreatedPlan.dinner.length, equals(1));

      expect(recreatedPlan.breakfast[0].id, equals('b1'));
      expect(recreatedPlan.lunch[0].id, equals('l1'));
      expect(recreatedPlan.snack[0].id, equals('s1'));
      expect(recreatedPlan.dinner[0].id, equals('d1'));
    });
  });
}
