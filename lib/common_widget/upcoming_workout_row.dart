import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class UpcomingWorkoutRow extends StatefulWidget {
  final Map wObj;
  const UpcomingWorkoutRow({super.key, required this.wObj});

  @override
  State<UpcomingWorkoutRow> createState() => _UpcomingWorkoutRowState();
}

class _UpcomingWorkoutRowState extends State<UpcomingWorkoutRow> {
  String _getLocalizedWorkoutName(BuildContext context, String workoutKey) {
    final localizations = AppLocalizations.of(context);
    switch (workoutKey) {
      case 'fullBodyWorkout':
        return localizations?.fullBodyWorkout ?? 'Full Body Workout';
      case 'lowerBodyWorkout':
        return localizations?.lowerBodyWorkout ?? 'Lower Body Workout';
      case 'abWorkout':
        return localizations?.abWorkout ?? 'Ab Workout';
      case 'fullbodyWorkout':
        return localizations?.fullbodyWorkout ?? 'Fullbody Workout';
      case 'upperbodyWorkout':
        return localizations?.upperbodyWorkout ?? 'Upperbody Workout';
      case 'lowerbodyWorkout':
        return localizations?.lowerbodyWorkout ?? 'Lowerbody Workout';
      default:
        return workoutKey;
    }
  }

  String _getLocalizedTime(BuildContext context, String timeText) {
    final localizations = AppLocalizations.of(context);
    if (timeText.startsWith('Today')) {
      return timeText.replaceFirst('Today', localizations?.today ?? 'Today');
    }
    return timeText;
  }

  String _cleanTitle(String title) {
    // Loại bỏ "Thứ" trong tên kiểu "Ngày 2 - Thứ Ba"
    return title.replaceAll(RegExp(r"\s*-?\s*Thứ\s*[A-Za-zÀ-ỹ]+", caseSensitive: false), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                widget.wObj["image"].toString(),
                width: 50,
                height: 50,
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
                  _cleanTitle(_getLocalizedWorkoutName(
                      context, widget.wObj["title"].toString())),
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  _getLocalizedTime(context, widget.wObj["time"].toString()),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 10,
                  ),
                ),
              ],
            )),
            // Toggle bị loại bỏ theo yêu cầu để giao diện gọn hơn
            const SizedBox.shrink(),
          ],
        ));
  }
}
