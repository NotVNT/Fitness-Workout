import 'package:fitness/common_widget/round_button.dart';
import 'package:flutter/material.dart';

import '../common/colo_extension.dart';

class FindEatCell extends StatelessWidget {
  final Map fObj;
  final int index;
  const FindEatCell({super.key, required this.index, required this.fObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    bool isEvent = index % 2 == 0;
    return Container(
      margin: const EdgeInsets.all(8),
      width: media.width * 0.45,
      height: 160, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isEvent ? TColor.primaryColor1 : TColor.secondaryColor1)
              .withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon thay thế hình ảnh
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isEvent
                      ? [TColor.primaryColor2, TColor.primaryColor1]
                      : [TColor.secondaryColor2, TColor.secondaryColor1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (isEvent
                            ? TColor.primaryColor1
                            : TColor.secondaryColor1)
                        .withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getCategoryIcon(fObj["name"]),
                color: TColor.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: Text(
                fObj["name"],
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              fObj["number"],
              style: TextStyle(color: TColor.gray, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: RoundButton(
                  fontSize: 11,
                  type: isEvent
                      ? RoundButtonType.bgGradient
                      : RoundButtonType.bgSGradient,
                  title: "Chọn",
                  onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method để lấy icon phù hợp cho danh mục
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('breakfast') || name.contains('sáng')) {
      return Icons.wb_sunny;
    } else if (name.contains('lunch') || name.contains('trưa')) {
      return Icons.lunch_dining;
    } else if (name.contains('dinner') || name.contains('tối')) {
      return Icons.dinner_dining;
    } else if (name.contains('snack') || name.contains('nhẹ')) {
      return Icons.cookie;
    } else {
      return Icons.restaurant_menu;
    }
  }
}
