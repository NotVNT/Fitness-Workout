import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/colo_extension.dart';
import '../models/meal_model.dart';
import '../providers/user_provider.dart';
import '../services/meal_recommendation_service.dart';
import '../l10n/app_localizations.dart';

class SmartMealRecommendation extends StatefulWidget {
  final MealCategory category;
  final Function(MealModel)? onMealSelected;

  const SmartMealRecommendation({
    super.key,
    required this.category,
    this.onMealSelected,
  });

  @override
  State<SmartMealRecommendation> createState() =>
      _SmartMealRecommendationState();
}

class _SmartMealRecommendationState extends State<SmartMealRecommendation> {
  List<MealModel> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      setState(() {
        recommendations = MealRecommendationService.getRecommendations(
          user: user,
          category: widget.category,
          limit: 3,
        );
        isLoading = false;
      });
    }
  }

  String _getCategoryRecommendationTitle() {
    switch (widget.category) {
      case MealCategory.breakfast:
        return AppLocalizations.of(context)?.recommendationForDiet ??
            'Gợi ý\ncho chế độ ăn';
      case MealCategory.lunch:
        return AppLocalizations.of(context)?.recommendationForDiet ??
            'Gợi ý\ncho chế độ ăn';
      case MealCategory.snack:
        return AppLocalizations.of(context)?.recommendationForDiet ??
            'Gợi ý\ncho chế độ ăn';
      case MealCategory.dinner:
        return AppLocalizations.of(context)?.dinnerRecommendations ??
            'Gợi ý\ncho bữa tối';
      case MealCategory.dessert:
        return 'Gợi ý\ncho tráng miệng';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(),
                color: TColor.primaryColor1,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _getCategoryRecommendationTitle(),
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.primaryG),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Thông minh',
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final meal = recommendations[index];
              return _buildMealCard(meal, index);
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case MealCategory.breakfast:
        return Icons.wb_sunny;
      case MealCategory.lunch:
        return Icons.lunch_dining;
      case MealCategory.snack:
        return Icons.cookie;
      case MealCategory.dinner:
        return Icons.dinner_dining;
      case MealCategory.dessert:
        return Icons.cake;
    }
  }

  Widget _buildMealCard(MealModel meal, int index) {
    bool isEven = index % 2 == 0;

    return Container(
      width: 160,
      height: 200, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isEven ? TColor.primaryColor1 : TColor.secondaryColor1)
              .withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Food icon instead of image
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isEven
                      ? [TColor.primaryColor2, TColor.primaryColor1]
                      : [TColor.secondaryColor2, TColor.secondaryColor1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getFoodIcon(meal.name),
                color: TColor.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),

            // Meal name
            Expanded(
              flex: 2,
              child: Text(
                meal.name,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            // Nutrition info in compact layout
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: TColor.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: TColor.primaryColor1,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${meal.calories.toInt()}',
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'kcal',
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            color: TColor.secondaryColor1,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${meal.protein.toInt()}g',
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'protein',
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Tags - simplified to avoid overflow
            if (meal.tags.isNotEmpty)
              Container(
                height: 16,
                child: Text(
                  meal.tags.take(1).join(', '),
                  style: TextStyle(
                    color:
                        isEven ? TColor.primaryColor1 : TColor.secondaryColor1,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 6),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.onMealSelected != null) {
                          widget.onMealSelected!(meal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Đã chọn ${meal.name} cho ${meal.getCategoryName()}'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: TColor.primaryColor1,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEven
                            ? TColor.primaryColor1
                            : TColor.secondaryColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Chọn',
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    onPressed: () {
                      _showMealDetails(meal);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: TColor.lightGray.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(
                      Icons.info_outline,
                      color: TColor.gray,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get appropriate food icon
  IconData _getFoodIcon(String foodName) {
    final name = foodName.toLowerCase();

    if (name.contains('phở') || name.contains('bún') || name.contains('miến')) {
      return Icons.ramen_dining;
    } else if (name.contains('cơm') || name.contains('gạo')) {
      return Icons.rice_bowl;
    } else if (name.contains('bánh') || name.contains('chè')) {
      return Icons.cake;
    } else if (name.contains('gà') ||
        name.contains('thịt') ||
        name.contains('heo')) {
      return Icons.lunch_dining;
    } else if (name.contains('cá') ||
        name.contains('tôm') ||
        name.contains('cua')) {
      return Icons.set_meal;
    } else if (name.contains('rau') ||
        name.contains('củ') ||
        name.contains('salad')) {
      return Icons.eco;
    } else if (name.contains('trứng')) {
      return Icons.egg;
    } else if (name.contains('sữa') ||
        name.contains('yaourt') ||
        name.contains('yogurt')) {
      return Icons.local_drink;
    } else if (name.contains('trái cây') || name.contains('hoa quả')) {
      return Icons.apple;
    } else {
      return Icons.restaurant;
    }
  }

  void _showMealDetails(MealModel meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMealDetailsSheet(meal),
    );
  }

  Widget _buildMealDetailsSheet(MealModel meal) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: TColor.gray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    meal.name,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    meal.nameEn,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nutrition summary
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Thông tin dinh dưỡng',
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNutritionItem(
                                'Calo', '${meal.calories.toInt()}', 'kcal'),
                            _buildNutritionItem(
                                'Protein', '${meal.protein.toInt()}', 'g'),
                            _buildNutritionItem(
                                'Carbs', '${meal.carbs.toInt()}', 'g'),
                            _buildNutritionItem(
                                'Fat', '${meal.fat.toInt()}', 'g'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Preparation info
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        '${meal.preparationTime} phút',
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        Icons.bar_chart,
                        meal.getDifficultyName(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Ingredients
                  Text(
                    'Nguyên liệu',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...meal.ingredients
                      .map((ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: TColor.primaryColor1,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  ingredient,
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: TColor.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: TColor.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: TColor.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: TColor.gray,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
