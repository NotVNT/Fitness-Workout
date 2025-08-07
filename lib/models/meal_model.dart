enum MealCategory {
  breakfast,
  lunch,
  snack,
  dinner,
  dessert,
}

enum MealDifficulty {
  easy,
  medium,
  hard,
}

class MealModel {
  final String id;
  final String name;
  final String nameEn;
  final MealCategory category;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final int preparationTime; // in minutes
  final MealDifficulty difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final bool isHealthy;
  final bool isVegetarian;
  final List<String> tags;
  final String? imageUrl;
  final bool useNetworkImage;

  MealModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.preparationTime,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    required this.isHealthy,
    required this.isVegetarian,
    required this.tags,
    this.imageUrl,
    this.useNetworkImage = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'category': category.toString(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'preparationTime': preparationTime,
      'difficulty': difficulty.toString(),
      'ingredients': ingredients,
      'instructions': instructions,
      'isHealthy': isHealthy,
      'isVegetarian': isVegetarian,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }

  // Create from JSON
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      category: MealCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
      preparationTime: json['preparationTime'],
      difficulty: MealDifficulty.values.firstWhere(
        (e) => e.toString() == json['difficulty'],
      ),
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      isHealthy: json['isHealthy'],
      isVegetarian: json['isVegetarian'],
      tags: List<String>.from(json['tags']),
      imageUrl: json['imageUrl'],
    );
  }

  // Get category display name
  String getCategoryName() {
    switch (category) {
      case MealCategory.breakfast:
        return 'Bữa sáng';
      case MealCategory.lunch:
        return 'Bữa trưa';
      case MealCategory.snack:
        return 'Bữa phụ';
      case MealCategory.dinner:
        return 'Bữa tối';
      case MealCategory.dessert:
        return 'Tráng miệng';
    }
  }

  // Get difficulty display name
  String getDifficultyName() {
    switch (difficulty) {
      case MealDifficulty.easy:
        return 'Dễ';
      case MealDifficulty.medium:
        return 'Vừa';
      case MealDifficulty.hard:
        return 'Khó';
    }
  }

  // Calculate protein percentage
  double get proteinPercentage {
    double proteinCalories = protein * 4; // 1g protein = 4 calories
    return (proteinCalories / calories) * 100;
  }

  // Calculate carbs percentage
  double get carbsPercentage {
    double carbsCalories = carbs * 4; // 1g carbs = 4 calories
    return (carbsCalories / calories) * 100;
  }

  // Calculate fat percentage
  double get fatPercentage {
    double fatCalories = fat * 9; // 1g fat = 9 calories
    return (fatCalories / calories) * 100;
  }

  // Check if meal is suitable for weight loss
  bool get isWeightLossFriendly {
    return calories < 400 && proteinPercentage > 20 && fiber > 3 && isHealthy;
  }

  // Get nutrition summary string
  String getNutritionSummary() {
    return '${calories.toInt()}kcal | ${protein.toInt()}g protein | ${carbs.toInt()}g carbs | ${fat.toInt()}g fat';
  }
}

class NutritionSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  // Get recommended daily values percentage
  double getCaloriesPercentage(double targetCalories) {
    return (calories / targetCalories) * 100;
  }

  double getProteinPercentage(double bodyWeight) {
    double recommendedProtein = bodyWeight * 1.2; // 1.2g per kg body weight
    return (protein / recommendedProtein) * 100;
  }
}

class DailyMealPlan {
  final List<MealModel> breakfast;
  final List<MealModel> lunch;
  final List<MealModel> snack;
  final List<MealModel> dinner;

  DailyMealPlan({
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.dinner,
  });

  // Get all meals in the plan
  List<MealModel> get allMeals {
    return [...breakfast, ...lunch, ...snack, ...dinner];
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast.map((meal) => meal.toJson()).toList(),
      'lunch': lunch.map((meal) => meal.toJson()).toList(),
      'snack': snack.map((meal) => meal.toJson()).toList(),
      'dinner': dinner.map((meal) => meal.toJson()).toList(),
    };
  }

  // Create from JSON
  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      breakfast: (json['breakfast'] as List<dynamic>)
          .map((mealJson) => MealModel.fromJson(mealJson))
          .toList(),
      lunch: (json['lunch'] as List<dynamic>)
          .map((mealJson) => MealModel.fromJson(mealJson))
          .toList(),
      snack: (json['snack'] as List<dynamic>)
          .map((mealJson) => MealModel.fromJson(mealJson))
          .toList(),
      dinner: (json['dinner'] as List<dynamic>)
          .map((mealJson) => MealModel.fromJson(mealJson))
          .toList(),
    );
  }

  // Calculate total nutrition for the day
  NutritionSummary get totalNutrition {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (var meal in allMeals) {
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
}
