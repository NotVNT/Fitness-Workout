import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';

class TodayMealRow extends StatelessWidget {
  final Map mObj;
  const TodayMealRow({super.key, required this.mObj});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TColor.primaryColor1.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              )
            ]),
        child: Row(
          children: [
            // Icon thay thế hình ảnh
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [TColor.primaryColor2, TColor.primaryColor1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _getMealIcon(mObj["name"].toString()),
                color: TColor.white,
                size: 18,
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
                    "${getDayTitle(mObj["time"].toString())} | ${getStringDateToOtherFormate(mObj["time"].toString(), outFormatStr: "h:mm aa")}",
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
                color: TColor.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: TColor.gray,
                size: 18,
              ),
            )
          ],
        ));
  }

  // Helper method để lấy icon phù hợp cho món ăn
  IconData _getMealIcon(String mealName) {
    final name = mealName.toLowerCase();

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
