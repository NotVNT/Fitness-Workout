import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/find_eat_cell.dart';
import '../../common_widget/smart_food_image.dart';
import '../../l10n/app_localizations.dart';
import '../../models/meal_model.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/user_provider.dart';
import 'meal_food_details_view.dart';

class MealPlannerView extends StatefulWidget {
  const MealPlannerView({super.key});

  @override
  State<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends State<MealPlannerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealPlanProvider>(context, listen: false).initialize();
    });
  }

  List<Map<String, String>> _getFindEatArr(BuildContext context) => [
        {
          "name": AppLocalizations.of(context)?.breakfast ?? "Breakfast",
          "image": "assets/img/m_3.png",
          "number": "120+ ${AppLocalizations.of(context)?.foods ?? "Foods"}"
        },
        {
          "name": AppLocalizations.of(context)?.lunch ?? "Lunch",
          "image": "assets/img/m_4.png",
          "number": "130+ ${AppLocalizations.of(context)?.foods ?? "Foods"}"
        },
        {
          "name": AppLocalizations.of(context)?.dinner ?? "Dinner",
          "image": "assets/img/m_1.png",
          "number": "80+ ${AppLocalizations.of(context)?.foods ?? "Foods"}"
        },
        {
          "name": AppLocalizations.of(context)?.snacks ?? "Snacks",
          "image": "assets/img/m_2.png",
          "number": "60+ ${AppLocalizations.of(context)?.foods ?? "Foods"}"
        },
        {
          "name": AppLocalizations.of(context)?.dessert ?? "Dessert",
          "image": "assets/img/m_5.png",
          "number": "40+ ${AppLocalizations.of(context)?.foods ?? "Foods"}"
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(
              Icons.arrow_back_ios,
              color: TColor.black,
              size: 16,
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)?.mealPlanner ?? "Kế hoạch bữa ăn",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          Consumer<MealPlanProvider>(
            builder: (context, mealPlanProvider, child) {
              return PopupMenuButton<String>(
                icon: Container(
                  margin: const EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    Icons.more_vert,
                    color: TColor.black,
                    size: 16,
                  ),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'auto_plan':
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      if (userProvider.user != null) {
                        await mealPlanProvider
                            .generateAutomaticPlan(userProvider.user!);
                      }
                      break;
                    case 'clear_plan':
                      // Lưu context trước khi async
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      await mealPlanProvider.clearPlan();

                      // Hiển thị thông báo xóa kế hoạch thành công
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.clear_all,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Đã xóa toàn bộ kế hoạch bữa ăn!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.orange.shade600,
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                      break;
                    case 'today':
                      await mealPlanProvider.goToToday();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'auto_plan',
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome),
                        SizedBox(width: 8),
                        Text('Tạo kế hoạch tự động'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_plan',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Xóa kế hoạch'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'today',
                    child: Row(
                      children: [
                        Icon(Icons.today),
                        SizedBox(width: 8),
                        Text('Về hôm nay'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: Consumer<MealPlanProvider>(
        builder: (context, mealPlanProvider, child) {
          if (mealPlanProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (mealPlanProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: TColor.gray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mealPlanProvider.error!,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      mealPlanProvider.clearError();
                      mealPlanProvider.initialize();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date selector
                _buildDateSelector(mealPlanProvider),

                // Daily nutrition summary
                if (mealPlanProvider.hasMeals)
                  _buildNutritionSummary(mealPlanProvider),

                // Meal plan sections
                _buildMealPlanSections(mealPlanProvider),

                // Find something to eat section
                _buildFindEatSection(),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(MealPlanProvider mealPlanProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColor.primaryColor1, TColor.primaryColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryColor1.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => mealPlanProvider.previousDay(),
                icon: Icon(
                  Icons.chevron_left,
                  color: TColor.white,
                  size: 28,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE', 'vi')
                          .format(mealPlanProvider.selectedDate),
                      style: TextStyle(
                        color: TColor.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(mealPlanProvider.selectedDate),
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => mealPlanProvider.nextDay(),
                icon: Icon(
                  Icons.chevron_right,
                  color: TColor.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickDateButton(
                  'Hôm qua',
                  () => mealPlanProvider.changeDate(
                    DateTime.now().subtract(const Duration(days: 1)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickDateButton(
                  'Hôm nay',
                  () => mealPlanProvider.goToToday(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickDateButton(
                  'Ngày mai',
                  () => mealPlanProvider.changeDate(
                    DateTime.now().add(const Duration(days: 1)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: TColor.white.withValues(alpha: 0.2),
        foregroundColor: TColor.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNutritionSummary(MealPlanProvider mealPlanProvider) {
    final nutrition = mealPlanProvider.dailyNutrition!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: TColor.primaryColor1,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Tổng dinh dưỡng trong ngày',
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Calo',
                  '${nutrition.calories.toInt()}',
                  'kcal',
                  TColor.primaryColor1,
                  Icons.local_fire_department,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Protein',
                  '${nutrition.protein.toInt()}',
                  'g',
                  Colors.orange,
                  Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Carbs',
                  '${nutrition.carbs.toInt()}',
                  'g',
                  Colors.blue,
                  Icons.grain,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Chất béo',
                  '${nutrition.fat.toInt()}',
                  'g',
                  Colors.green,
                  Icons.opacity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
      String label, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanSections(MealPlanProvider mealPlanProvider) {
    return Column(
      children: [
        _buildMealSection(
          'Bữa sáng',
          Icons.wb_sunny_outlined,
          mealPlanProvider.breakfastMeals,
          mealPlanProvider.getCategoricalCalories(MealCategory.breakfast),
          Colors.orange,
        ),
        _buildMealSection(
          'Bữa trưa',
          Icons.wb_sunny,
          mealPlanProvider.lunchMeals,
          mealPlanProvider.getCategoricalCalories(MealCategory.lunch),
          Colors.blue,
        ),
        _buildMealSection(
          'Bữa tối',
          Icons.nightlight_round,
          mealPlanProvider.dinnerMeals,
          mealPlanProvider.getCategoricalCalories(MealCategory.dinner),
          Colors.purple,
        ),
        _buildMealSection(
          'Đồ ăn vặt',
          Icons.cookie_outlined,
          mealPlanProvider.snackMeals,
          mealPlanProvider.getCategoricalCalories(MealCategory.snack),
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMealSection(String title, IconData icon, List<MealModel> meals,
      double calories, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${meals.length} món | ${calories.toInt()} kcal',
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (meals.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: TColor.gray,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có món ăn nào',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm món ăn từ phần "Tìm món ăn" bên dưới',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: meals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final meal = meals[index];
                return _buildMealItem(meal);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMealItem(MealModel meal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColor.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SmartFoodImage(
              foodName: meal.name,
              width: 50,
              height: 50,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.getNutritionSummary(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Lưu tên món ăn trước khi xóa
              final mealName = meal.name;

              // Xóa món ăn
              Provider.of<MealPlanProvider>(context, listen: false)
                  .removeMeal(meal.id);

              // Hiển thị thông báo xóa thành công
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đã xóa món "$mealName" khỏi kế hoạch!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red.shade600,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                  action: SnackBarAction(
                    label: 'Hoàn tác',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Implement undo functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Tính năng hoàn tác đang được phát triển'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindEatSection() {
    final findEatArr = _getFindEatArr(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: TColor.primaryColor1,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.findSomethingToEat ??
                    "Tìm món ăn",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              itemCount: findEatArr.length,
              itemBuilder: (context, index) {
                var fObj = findEatArr[index] as Map? ?? {};
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealFoodDetailsView(
                            eObj: fObj,
                            onMealSelected: (selectedMeal) {
                              // Convert to MealModel and add to plan
                              final mealModel = _convertToMealModel(
                                  selectedMeal, fObj["name"] ?? "");
                              Provider.of<MealPlanProvider>(context,
                                      listen: false)
                                  .addMeal(mealModel);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    child: FindEatCell(
                      fObj: fObj,
                      index: index,
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  MealModel _convertToMealModel(Map selectedMeal, String categoryName) {
    MealCategory category;
    switch (categoryName.toLowerCase()) {
      case 'breakfast':
      case 'bữa sáng':
        category = MealCategory.breakfast;
        break;
      case 'lunch':
      case 'bữa trưa':
        category = MealCategory.lunch;
        break;
      case 'dinner':
      case 'bữa tối':
        category = MealCategory.dinner;
        break;
      case 'snacks':
      case 'đồ ăn vặt':
        category = MealCategory.snack;
        break;
      case 'dessert':
      case 'tráng miệng':
        category = MealCategory.dessert;
        break;
      default:
        category = MealCategory.snack;
    }

    return MealModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: selectedMeal['name'] ?? 'Món ăn',
      nameEn: selectedMeal['name'] ?? 'Food',
      category: category,
      calories: _parseDouble(selectedMeal['kcal']),
      protein: _parseDouble(selectedMeal['protein']),
      carbs: _parseDouble(selectedMeal['carbs']),
      fat: _parseDouble(selectedMeal['fat']),
      fiber: 2.0, // Default value
      preparationTime: _parseInt(selectedMeal['time']),
      difficulty: MealDifficulty.easy,
      ingredients: [],
      instructions: [],
      isHealthy: true,
      isVegetarian: false,
      tags: [],
      imageUrl: selectedMeal['image'],
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    String str = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(str) ?? 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 15;
    String str = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(str) ?? 15;
  }
}
