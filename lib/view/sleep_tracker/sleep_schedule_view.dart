import 'package:fitness/view/sleep_tracker/sleep_add_alarm_view.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/today_sleep_schedule_row.dart';
import '../../l10n/app_localizations.dart';
import '../../models/sleep_schedule.dart';
import '../../services/sleep_schedule_service.dart';

class SleepScheduleView extends StatefulWidget {
  const SleepScheduleView({super.key});

  @override
  State<SleepScheduleView> createState() => _SleepScheduleViewState();
}

class _SleepScheduleViewState extends State<SleepScheduleView> {
  late DateTime _selectedDate;
  SleepSchedule? _schedule;


  List<Map<String, String>> get todaySleepArr {
        final bedtimeText = AppLocalizations.of(context)?.bedtime ?? 'Giờ đi ngủ';
        final alarmText = AppLocalizations.of(context)?.alarm ?? 'Báo thức';
        return _buildSleepList(bedtimeText, alarmText);
      }

      List<Map<String, String>> _buildSleepList(String bedtimeText, String alarmText) {
        if (_schedule != null) {
          final bed = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _schedule!.bedtimeHour, _schedule!.bedtimeMinute);
          final wake = bed.add(Duration(hours: _schedule!.sleepHours, minutes: _schedule!.sleepMinutes));
          return [
            {
              "name": bedtimeText,
              "image": "assets/img/bed.png",
              "time": "${bed.day}/${bed.month}/${bed.year} ${_formatTime(bed)}",
              "duration": AppLocalizations.of(context)?.inHoursMinutes('0', '0') ?? ''
            },
            {
              "name": alarmText,
              "image": "assets/img/alaarm.png",
              "time": "${wake.day}/${wake.month}/${wake.year} ${_formatTime(wake)}",
              "duration": AppLocalizations.of(context)?.inHoursMinutes('${_schedule!.sleepHours}', '${_schedule!.sleepMinutes}') ?? ''
            },
          ];
        }
        // Dữ liệu giả nếu chưa có thiết lập
        return [
          {
            "name": bedtimeText,
            "image": "assets/img/bed.png",
            "time": "01/06/2023 09:00 PM",
            "duration": AppLocalizations.of(context)?.inHoursMinutes('6', '22') ?? 'trong 6 giờ 22 phút'
          },
          {
            "name": alarmText,
            "image": "assets/img/alaarm.png",
            "time": "02/06/2023 05:10 AM",
            "duration": AppLocalizations.of(context)?.inHoursMinutes('14', '30') ?? 'trong 14 giờ 30 phút'
          },
        ];
      }

      String _formatTime(DateTime dt) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        return '$hour:$minute $ampm';
      }


  List<int> showingTooltipOnSpots = [4];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    _schedule = await SleepScheduleService.load(_selectedDate);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
          AppLocalizations.of(context)?.sleepSchedule ?? "Sleep Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
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
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(20),
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          TColor.primaryColor2.withValues(alpha: 0.4),
                          TColor.primaryColor1.withValues(alpha: 0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                AppLocalizations.of(context)
                                        ?.idealHoursForSleep ??
                                    "Ideal Hours for Sleep",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)
                                        ?.hoursMinutes('8', '30') ??
                                    "8hours 30minutes",
                                style: TextStyle(
                                    color: TColor.primaryColor2,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 110,
                                height: 35,
                                child: RoundButton(
                                    icon: Icons.info_outline,
                                    iconSize: 16,
                                    onPressed: () {}),
                              )
                            ]),
                        Image.asset(
                          "assets/img/sleep_schedule.png",
                          width: media.width * 0.35,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.yourSchedule ??
                            "Your Schedule",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: TColor.primaryG),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: todaySleepArr.length,
                    itemBuilder: (context, index) {
                      var sObj = todaySleepArr[index] as Map? ?? {};
                      return TodaySleepScheduleRow(
                        sObj: sObj,
                      );
                    }),
                Container(
                    width: double.maxFinite,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          TColor.secondaryColor2.withValues(alpha: 0.4),
                          TColor.secondaryColor1.withValues(alpha: 0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)?.hoursMinutes('8', '10') ?? '8hours 10minutes'}\n${AppLocalizations.of(context)?.today ?? 'for tonight'}',
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: media.width - 90,
                              child: LinearPercentIndicator(
                                lineHeight: 15,
                                percent: 0.96,
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
                            Text(
                              "96%",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SleepAddAlarmView(
                date: _selectedDate,
              ),
            ),
          );
          if (changed == true) setState(() {});
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}
