import 'package:fitness/common_widget/round_button.dart';
import 'package:flutter/material.dart';

import '../common/colo_extension.dart';
import '../l10n/app_localizations.dart';

class WhatTrainRow extends StatelessWidget {
  final Map wObj;
  const WhatTrainRow({super.key, required this.wObj});

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

  String _getLocalizedExercises(BuildContext context, String exercisesText) {
    final localizations = AppLocalizations.of(context);
    if (exercisesText.contains('exercises')) {
      final number = exercisesText.split(' ')[0];
      return '$number ${localizations?.exercises ?? "Exercises"}';
    }
    return exercisesText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              TColor.primaryColor2.withValues(alpha: 0.3),
              TColor.primaryColor1.withValues(alpha: 0.3)
            ]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedWorkoutName(
                          context, wObj["title"].toString()),
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${_getLocalizedExercises(context, wObj["exercises"].toString())} | ${wObj["time"].toString()}",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: RoundButton(
                          icon: Icons.arrow_forward,
                          iconSize: 16,
                          type: RoundButtonType.textGradient,
                          elevation: 0.05,
                          onPressed: () {}),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      wObj["image"].toString(),
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
