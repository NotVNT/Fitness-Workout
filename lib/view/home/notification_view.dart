import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/notification_row.dart';
import '../../l10n/app_localizations.dart';
import '../../services/workout_reminder_service.dart';
import '../../services/activity_log_service.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List notificationArr = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Đọc giờ nhắc tập luyện đã lưu và thêm 1 thông báo mô phỏng
    final reminder = await WorkoutReminderService.load();
    if (!mounted) return;
    setState(() {
      notificationArr = [
        if (reminder != null)
          {
            "image": "assets/img/Workout1.png",
            "title": "Đến giờ tập luyện!",
            "time": "${reminder.h.toString().padLeft(2, '0')}:${reminder.m.toString().padLeft(2, '0')}",
          },
      ];
    });
  }

  void _clearAll() async {
    if (notificationArr.isEmpty) return;
    final count = notificationArr.length;
    setState(() => notificationArr.clear());
    // Log action
    await ActivityLogService.logNotificationsCleared(count);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa tất cả thông báo')),
    );
  }

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
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)?.notification ?? 'Thông báo',
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {
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
                        leading: const Icon(Icons.delete_sweep),
                        title: const Text('Xóa tất cả thông báo'),
                        onTap: () {
                          Navigator.pop(ctx);
                          _clearAll();
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
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemBuilder: ((context, index) {
          var nObj = notificationArr[index] as Map? ?? {};
          return NotificationRow(
            nObj: nObj,
            onDelete: () async {
              setState(() {
                notificationArr.removeAt(index);
              });
              await ActivityLogService.logNotificationDeleted(nObj['title'] as String?);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa thông báo')),
              );
            },
          );
      }), separatorBuilder: (context, index){
        return Divider(color: TColor.gray.withValues(alpha: 0.5), height: 1, );
      }, itemCount: notificationArr.length),
    );
  }
}
