import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

class PopularMealRow extends StatelessWidget {
  final Map mObj;
  final VoidCallback? onTap;
  const PopularMealRow({super.key, required this.mObj, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            // Thay thế hình ảnh bằng icon thực phẩm
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 30,
                color: TColor.primaryColor1,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mObj["name"].toString(),
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    "${mObj["size"]} | ${mObj["time"]} | ${mObj["kcal"]}",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: onTap ?? () {},
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: TColor.gray,
              ),
            )
          ],
        ));
  }
}
