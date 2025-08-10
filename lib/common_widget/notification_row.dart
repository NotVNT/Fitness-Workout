
import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

class NotificationRow extends StatelessWidget {
  final Map nObj;
  final VoidCallback? onDelete;
  const NotificationRow({super.key, required this.nObj, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              nObj["image"].toString(),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
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
                nObj["title"].toString(),
                style: TextStyle(
                    color: TColor.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              Text(
                nObj["time"].toString(),
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 10,
                ),
              ),
            ],
          )),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Xóa thông báo này'),
                          onTap: () {
                            Navigator.pop(ctx);
                            onDelete?.call();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.close),
                          title: const Text('Đóng'),
                          onTap: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: Image.asset(
                "assets/img/sub_menu.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ))
        ],
      ),
    );
  }
}