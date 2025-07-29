import 'package:animated_toggle_switch/animated_toggle_switch.dart';
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
  bool positive = false;

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
                  _getLocalizedWorkoutName(
                      context, widget.wObj["title"].toString()),
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.wObj["time"].toString(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 10,
                  ),
                ),
              ],
            )),
            Flexible(
              child: CustomAnimatedToggleSwitch<bool>(
                current: positive,
                values: [false, true],
                indicatorSize: const Size.square(28.0),
                animationDuration: const Duration(milliseconds: 200),
                animationCurve: Curves.linear,
                onChanged: (b) => setState(() => positive = b),
                iconBuilder: (context, local, global) {
                  return const SizedBox();
                },
                onTap: (tapProperties) => setState(
                    () => positive = tapProperties.tapped?.value ?? !positive),
                iconsTappable: false,
                wrapperBuilder: (context, global, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          left: 10.0,
                          right: 10.0,
                          height: 30.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient:
                                  LinearGradient(colors: TColor.secondaryG),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50.0)),
                            ),
                          )),
                      child,
                    ],
                  );
                },
                foregroundIndicatorBuilder: (context, global) {
                  return SizedBox.fromSize(
                    size: const Size(10, 10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50.0)),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black38,
                              spreadRadius: 0.05,
                              blurRadius: 1.1,
                              offset: Offset(0.0, 0.8))
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
