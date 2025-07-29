import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../common/colo_extension.dart';

class NutritionRow extends StatelessWidget {
  final Map nObj;
  const NutritionRow({super.key, required this.nObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    var val = double.tryParse(nObj["value"].toString()) ?? 1;
    var maxVal = double.tryParse(nObj["max_value"].toString()) ?? 1;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(children: [
        Row(
          children: [
            Text(
              nObj["title"].toString(),
              style: TextStyle(
                  color: TColor.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              width: 4,
            ),
            Image.asset(
              nObj["image"].toString(),
              width: 15,
              height: 15,
            ),
            const Spacer(),
            Text(
              "${nObj["value"].toString()} ${nObj["unit_name"].toString()}",
              style: TextStyle(color: TColor.gray, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        SizedBox(
          width: media.width - 40,
          child: LinearPercentIndicator(
            lineHeight: 10,
            percent: val / maxVal,
            backgroundColor: Colors.grey.shade100,
            linearGradient: LinearGradient(
                colors: TColor.primaryG,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
            barRadius: Radius.circular(7.5),
            animation: true,
            animationDuration: 3000,
          ),
        ),
      ]),
    );
  }
}
