import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/colo_extension.dart';
import '../../providers/user_provider.dart';

class MealFoodDetailsView extends StatefulWidget {
  final Map eObj;
  final Function(Map)? onMealSelected;
  const MealFoodDetailsView(
      {super.key, required this.eObj, this.onMealSelected});

  @override
  State<MealFoodDetailsView> createState() => _MealFoodDetailsViewState();
}

class _MealFoodDetailsViewState extends State<MealFoodDetailsView> {
  TextEditingController txtSearch = TextEditingController();
  List<Map<String, dynamic>> filteredMeals = [];
  List<Map<String, dynamic>> allMeals = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeMeals();
    txtSearch.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    txtSearch.removeListener(_onSearchChanged);
    txtSearch.dispose();
    super.dispose();
  }

  void _initializeMeals() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bmi = userProvider.bmi;

    // Chọn danh sách món ăn dựa trên BMI
    if (bmi > 25) {
      allMeals = weightLossBreakfastArr;
    } else if (bmi < 18.5) {
      allMeals = weightGainBreakfastArr;
    } else {
      allMeals = normalBreakfastArr;
    }

    filteredMeals = List.from(allMeals);
  }

  void _onSearchChanged() {
    setState(() {
      isSearching = txtSearch.text.isNotEmpty;
      if (isSearching) {
        filteredMeals = allMeals.where((meal) {
          final name = meal['name'].toString().toLowerCase();
          final description =
              meal['description']?.toString().toLowerCase() ?? '';
          final searchTerm = txtSearch.text.toLowerCase();

          // Search với dấu
          final hasAccentMatch =
              name.contains(searchTerm) || description.contains(searchTerm);

          // Search không dấu
          final nameWithoutAccent = _removeVietnameseAccents(name);
          final descriptionWithoutAccent =
              _removeVietnameseAccents(description);
          final searchTermWithoutAccent = _removeVietnameseAccents(searchTerm);
          final hasNoAccentMatch =
              nameWithoutAccent.contains(searchTermWithoutAccent) ||
                  descriptionWithoutAccent.contains(searchTermWithoutAccent);

          return hasAccentMatch || hasNoAccentMatch;
        }).toList();
      } else {
        filteredMeals = List.from(allMeals);
      }
    });
  }

  // Function để chuyển đổi tiếng Việt có dấu thành không dấu
  String _removeVietnameseAccents(String str) {
    const vietnamese =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const english =
        'aaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

    String result = str.toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], english[i]);
    }
    return result;
  }

  String _getBMIRecommendationText() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bmi = userProvider.bmi;

    if (bmi > 25) {
      return "Dành cho người cần giảm cân (BMI: ${bmi.toStringAsFixed(1)})";
    } else if (bmi < 18.5) {
      return "Dành cho người cần tăng cân (BMI: ${bmi.toStringAsFixed(1)})";
    } else {
      return "Dành cho người duy trì cân nặng (BMI: ${bmi.toStringAsFixed(1)})";
    }
  }

  // Món ăn bữa sáng cho người giảm cân (BMI > 25)
  List<Map<String, dynamic>> get weightLossBreakfastArr => [
        {
          "name": "Cháo yến mạch hạt chia",
          "size": "Ít calo",
          "time": "10 phút",
          "kcal": "180kCal",
          "protein": "8g",
          "carbs": "25g",
          "fat": "4g",
          "description": "Giàu chất xơ, giúp no lâu và kiểm soát cân nặng"
        },
        {
          "name": "Bánh mì nguyên cám không nhân",
          "size": "Ít calo",
          "time": "5 phút",
          "kcal": "150kCal",
          "protein": "6g",
          "carbs": "28g",
          "fat": "2g",
          "description": "Chất xơ cao, ít đường, phù hợp giảm cân"
        },
        {
          "name": "Trứng luộc với rau xanh",
          "size": "Ít calo",
          "time": "8 phút",
          "kcal": "120kCal",
          "protein": "12g",
          "carbs": "5g",
          "fat": "8g",
          "description": "Protein cao, ít carbs, tốt cho giảm cân"
        },
        {
          "name": "Sinh tố xanh không đường",
          "size": "Ít calo",
          "time": "5 phút",
          "kcal": "100kCal",
          "protein": "4g",
          "carbs": "20g",
          "fat": "1g",
          "description": "Vitamin cao, detox tự nhiên, hỗ trợ giảm cân"
        },
        {
          "name": "Phở gà không dầu mỡ",
          "size": "Ít calo",
          "time": "20 phút",
          "kcal": "220kCal",
          "protein": "18g",
          "carbs": "30g",
          "fat": "4g",
          "description": "Nước dùng trong, thịt gà nạc, ít bánh phở"
        },
      ];

  // Món ăn bữa sáng cho người cân nặng bình thường (BMI 18.5-25)
  List<Map<String, dynamic>> get normalBreakfastArr => [
        {
          "name": "Phở gà truyền thống",
          "size": "Vừa phải",
          "time": "15 phút",
          "kcal": "280kCal",
          "protein": "22g",
          "carbs": "35g",
          "fat": "6g",
          "description": "Cân bằng dinh dưỡng, hương vị truyền thống"
        },
        {
          "name": "Bánh cuốn chả cá",
          "size": "Vừa phải",
          "time": "12 phút",
          "kcal": "250kCal",
          "protein": "15g",
          "carbs": "30g",
          "fat": "8g",
          "description": "Nhẹ nhàng, dễ tiêu hóa, đủ chất"
        },
        {
          "name": "Cháo tôm rau cải",
          "size": "Vừa phải",
          "time": "18 phút",
          "kcal": "200kCal",
          "protein": "12g",
          "carbs": "28g",
          "fat": "5g",
          "description": "Protein từ tôm, nhiều rau xanh"
        },
      ];

  // Món ăn bữa sáng cho người tăng cân (BMI < 18.5)
  List<Map<String, dynamic>> get weightGainBreakfastArr => [
        {
          "name": "Bánh mì thịt nướng",
          "size": "Nhiều calo",
          "time": "10 phút",
          "kcal": "380kCal",
          "protein": "18g",
          "carbs": "45g",
          "fat": "12g",
          "description": "Protein cao, carbs phức hợp, năng lượng dồi dào"
        },
        {
          "name": "Cháo thịt bò hạt sen",
          "size": "Nhiều calo",
          "time": "25 phút",
          "kcal": "320kCal",
          "protein": "20g",
          "carbs": "35g",
          "fat": "10g",
          "description": "Dinh dưỡng cao, dễ tiêu hóa, tốt cho tăng cân"
        },
        {
          "name": "Sinh tố bơ chuối sữa",
          "size": "Nhiều calo",
          "time": "5 phút",
          "kcal": "350kCal",
          "protein": "12g",
          "carbs": "40g",
          "fat": "18g",
          "description": "Chất béo tốt, vitamin, khoáng chất phong phú"
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
          widget.eObj["name"].toString(),
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                Icons.more_horiz,
                color: TColor.black,
                size: 20,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: Column(
        children: [
          // Header với search bar đẹp
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [TColor.primaryColor1, TColor.primaryColor2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: TColor.gray,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: txtSearch,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Tìm món ăn...",
                            hintStyle: TextStyle(
                              color: TColor.gray,
                              fontSize: 16,
                            ),
                          ),
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isSearching)
                        IconButton(
                          onPressed: () {
                            txtSearch.clear();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: TColor.gray,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // BMI recommendation text
                Text(
                  "Gợi ý món ăn cho bạn",
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getBMIRecommendationText(),
                  style: TextStyle(
                    color: TColor.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Body với danh sách món ăn
          Expanded(
            child: filteredMeals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = filteredMeals[index];
                      return _buildMealCard(meal, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: TColor.gray,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'Không tìm thấy món ăn nào' : 'Chưa có món ăn',
            style: TextStyle(
              color: TColor.gray,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Danh sách món ăn đang được cập nhật',
            style: TextStyle(
              color: TColor.gray,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon và tên món
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColor.primaryColor1.withValues(alpha: 0.1),
                  TColor.primaryColor2.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: TColor.primaryColor1.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _getMealIcon(meal['name']),
                        color: TColor.primaryColor1,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        meal['name'] ?? '',
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onMealSelected != null) {
                          widget.onMealSelected!(meal);
                        }

                        // Hiển thị thông báo thành công
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Đã chọn món "${meal['name']}" thành công!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primaryColor1,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Chọn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 66), // Offset for icon + spacing
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: TColor.gray,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meal['time'] ?? '',
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getSizeColor(meal['size']),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              meal['size'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nutrition info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildNutritionChip(
                      meal['kcal'] ?? '0',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    _buildNutritionChip(
                      meal['protein'] ?? '0',
                      Icons.fitness_center,
                      Colors.blue,
                    ),
                    _buildNutritionChip(
                      meal['carbs'] ?? '0',
                      Icons.grain,
                      Colors.green,
                    ),
                    _buildNutritionChip(
                      meal['fat'] ?? '0',
                      Icons.opacity,
                      Colors.purple,
                    ),
                  ],
                ),
                if (meal['description'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    meal['description'],
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String? mealName) {
    if (mealName == null) return Icons.restaurant;

    final name = mealName.toLowerCase();
    if (name.contains('phở') || name.contains('cháo')) {
      return Icons.ramen_dining;
    } else if (name.contains('bánh') || name.contains('mì')) {
      return Icons.bakery_dining;
    } else if (name.contains('trứng')) {
      return Icons.egg;
    } else if (name.contains('sinh tố') || name.contains('nước')) {
      return Icons.local_drink;
    } else if (name.contains('gỏi') || name.contains('salad')) {
      return Icons.eco;
    } else if (name.contains('thịt') ||
        name.contains('gà') ||
        name.contains('cá')) {
      return Icons.set_meal;
    } else {
      return Icons.restaurant;
    }
  }

  Color _getSizeColor(String? size) {
    switch (size) {
      case 'Ít calo':
        return Colors.green;
      case 'Nhiều calo':
        return Colors.orange;
      case 'Vừa phải':
        return Colors.blue;
      default:
        return TColor.gray;
    }
  }
}
