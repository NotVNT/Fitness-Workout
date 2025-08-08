import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

class MealFoodScheduleRow extends StatelessWidget {
  final Map mObj;
  final int index;
  const MealFoodScheduleRow(
      {super.key, required this.mObj, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                (index % 2 == 0 ? TColor.primaryColor1 : TColor.secondaryColor1)
                    .withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon thay thế hình ảnh
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: index % 2 == 0
                      ? [TColor.primaryColor2, TColor.primaryColor1]
                      : [TColor.secondaryColor2, TColor.secondaryColor1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getFoodIcon(mObj["name"].toString()),
                color: TColor.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mObj["name"].toString(),
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mObj["time"].toString(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TColor.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: TColor.gray,
                size: 16,
              ),
            )
          ],
        ));
  }

  // Helper method để lấy icon phù hợp cho món ăn
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
}
