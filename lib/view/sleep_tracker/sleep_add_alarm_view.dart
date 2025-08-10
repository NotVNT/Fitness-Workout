import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';
import '../../l10n/app_localizations.dart';
import '../../models/sleep_schedule.dart';
import '../../services/sleep_schedule_service.dart';

class SleepAddAlarmView extends StatefulWidget {
  final DateTime date;
  const SleepAddAlarmView({super.key, required this.date});

  @override
  State<SleepAddAlarmView> createState() => _SleepAddAlarmViewState();
}

class _SleepAddAlarmViewState extends State<SleepAddAlarmView> {
  bool positive = false;

  TimeOfDay _bedTime = const TimeOfDay(hour: 21, minute: 0);
  int _sleepHours = 8;
  int _sleepMinutes = 30;
  String _repeat = 'Mon to Fri';

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final loaded = await SleepScheduleService.load(widget.date);
    if (loaded != null) {
      setState(() {
        _bedTime = TimeOfDay(hour: loaded.bedtimeHour, minute: loaded.bedtimeMinute);
        _sleepHours = loaded.sleepHours;
        _sleepMinutes = loaded.sleepMinutes;
        positive = loaded.vibrate;
        _repeat = loaded.repeat;
      });
    }
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
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)?.addAlarm ?? "Add Alarm",
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
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/img/Bed_Add.png",
              title: AppLocalizations.of(context)?.bedtime ?? "Giờ đi ngủ",
              time: _bedTime.format(context),
              color: TColor.lightGray,
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _bedTime,
                );
                if (picked != null) {
                  setState(() => _bedTime = picked);
                }
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/HoursTime.png",
              title: AppLocalizations.of(context)?.hoursOfSleep ??
                  "Số giờ ngủ",
              time: AppLocalizations.of(context)?.hoursMinutes(_sleepHours.toString(), _sleepMinutes.toString()) ?? '${_sleepHours}hours ${_sleepMinutes}minutes',
              color: TColor.lightGray,
              onPressed: () async {
                // Hiển thị bottom sheet đơn giản chọn giờ & phút
                final result = await showModalBottomSheet<Map<String, int>>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (ctx) {
                    int hours = _sleepHours;
                    int minutes = _sleepMinutes;
                    return StatefulBuilder(builder: (ctx, setSt) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)?.hoursOfSleep ?? 'Số giờ ngủ', style: TextStyle(fontWeight: FontWeight.w600, color: TColor.black)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                DropdownButton<int>(
                                  value: hours,
                                  items: List.generate(13, (i) => i)
                                      .map((e) => DropdownMenuItem(value: e, child: Text('$e h')))
                                      .toList(),
                                  onChanged: (v) => setSt(() => hours = v ?? hours),
                                ),
                                DropdownButton<int>(
                                  value: minutes,
                                  items: [0, 15, 30, 45]
                                      .map((e) => DropdownMenuItem(value: e, child: Text('$e m')))
                                      .toList(),
                                  onChanged: (v) => setSt(() => minutes = v ?? minutes),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, {'h': hours, 'm': minutes}),
                              child: Text(AppLocalizations.of(context)?.save ?? 'Lưu'),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                );

                if (result != null) {
                  setState(() {
                    _sleepHours = result['h'] ?? _sleepHours;
                    _sleepMinutes = result['m'] ?? _sleepMinutes;
                  });
                }
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/Repeat.png",
              title: AppLocalizations.of(context)?.repeat ?? "Lặp lại",
              time: _repeat,
              color: TColor.lightGray,
              onPressed: () async {
                final options = ['Mon to Fri', 'Everyday', 'Weekends'];
                final vi = [
                  'T2 - T6',
                  'Mỗi ngày',
                  'Cuối tuần',
                ];
                final selected = await showModalBottomSheet<int>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (ctx) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(options.length, (i) {
                          return ListTile(
                            title: Text(vi[i]),
                            onTap: () => Navigator.pop(ctx, i),
                          );
                        }),
                      ),
                    );
                  },
                );
                if (selected != null) {
                  setState(() => _repeat = vi[selected]);
                }
              }),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 15,
                ),
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/img/Vibrate.png",
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.vibrateWhenAlarmSound ??
                        "Vibrate When Alarm Sound",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Transform.scale(
                    scale: 0.7,
                    child: CustomAnimatedToggleSwitch<bool>(
                      current: positive,
                      values: [false, true],
                      indicatorSize: const Size.square(30.0),
                      animationDuration: const Duration(milliseconds: 200),
                      animationCurve: Curves.linear,
                      onChanged: (b) => setState(() => positive = b),
                      iconBuilder: (context, local, global) {
                        return const SizedBox();
                      },
                      onTap: (tapProperties) => setState(() =>
                          positive = tapProperties.tapped?.value ?? !positive),
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
                                    gradient: LinearGradient(
                                        colors: TColor.primaryG),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0)),
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
                )
              ],
            ),
          ),
          const Spacer(),
          RoundButton(
              title: AppLocalizations.of(context)?.add ?? "Thêm",
              onPressed: () async {
                final schedule = SleepSchedule(
                  bedtimeHour: _bedTime.hour,
                  bedtimeMinute: _bedTime.minute,
                  sleepHours: _sleepHours,
                  sleepMinutes: _sleepMinutes,
                  vibrate: positive,
                  repeat: _repeat,
                );
                await SleepScheduleService.save(widget.date, schedule);
                if (!mounted) return; Navigator.pop(context, true);
              }),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
