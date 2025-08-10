import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/icon_text_button.dart';
import '../../l10n/app_localizations.dart';
import 'comparison_view.dart';

class PhotoProgressView extends StatefulWidget {
  const PhotoProgressView({super.key});

  @override
  State<PhotoProgressView> createState() => _PhotoProgressViewState();
}

class _PhotoProgressViewState extends State<PhotoProgressView> {
  bool _showReminder = true; // State để quản lý việc hiển thị reminder
  int _reminderDay = 8; // Ngày trong tháng để nhắc chụp ảnh (1..28)

  DateTime _computeNextReminderDate() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final thisMonthLastDay = DateTime(year, month + 1, 0).day;
    final desiredDay = _reminderDay.clamp(1, 28);

    if (now.day <= desiredDay && desiredDay <= thisMonthLastDay) {
      return DateTime(year, month, desiredDay);
    } else {
      final nextMonthLastDay = DateTime(year, month + 2, 0).day;
      final safeDay =
          desiredDay <= nextMonthLastDay ? desiredDay : nextMonthLastDay;
      return DateTime(year, month + 1, safeDay);
    }
  }

  String _formatMonthDay(DateTime d) {
    final locale = Localizations.localeOf(context).languageCode;
    final pattern = locale == 'vi' ? 'dd MMMM' : 'MMMM dd';
    return DateFormat(pattern, locale).format(d);
  }

  String _reminderDescription() {
    final next = _computeNextReminderDate();
    final dateStr = _formatMonthDay(next);
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'vi'
        ? 'Ảnh tiếp theo vào ngày $dateStr'
        : 'Next photos on $dateStr';
  }

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  // Load trạng thái reminder từ SharedPreferences
  _loadReminderState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _showReminder = prefs.getBool('show_photo_reminder') ?? true;
      _reminderDay = prefs.getInt('reminder_day') ?? 8;
    });
  }

  // Save trạng thái reminder vào SharedPreferences
  _saveReminderState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_photo_reminder', value);
  }

  // Lưu ngày nhắc nhở
  _saveReminderDay(int day) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_day', day);
  }

  // Reset reminder (có thể dùng cho testing hoặc settings)
  _resetReminder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_photo_reminder', true);
    await prefs.setInt('reminder_day', 8);
    setState(() {
      _showReminder = true;
      _reminderDay = 8;
    });
  }

  // Mở bottom sheet cài đặt theo dõi tiến độ
  void _showTrackProgressOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int tempDay = _reminderDay;
        bool tempShow = _showReminder;
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: TColor.primaryColor1),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.trackYourProgress ??
                            'Theo dõi tiến độ của bạn mỗi tháng bằng ảnh',
                        style: TextStyle(
                            fontSize: 14,
                            color: TColor.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Bật nhắc nhở hàng tháng',
                      style: TextStyle(color: TColor.black)),
                  value: tempShow,
                  onChanged: (v) {
                    setModalState(() => tempShow = v);
                    setState(() => _showReminder = v);
                    _saveReminderState(v);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ngày nhắc mỗi tháng',
                        style: TextStyle(color: TColor.black)),
                    DropdownButton<int>(
                      value: tempDay,
                      items: List.generate(28, (i) => i + 1)
                          .map((d) => DropdownMenuItem<int>(
                                value: d,
                                child: Text(d.toString()),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setModalState(() => tempDay = v);
                        setState(() => _reminderDay = v);
                        _saveReminderDay(v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: RoundButton(
                    type: RoundButtonType.bgSGradient,
                    title: AppLocalizations.of(context)?.compareMyPhoto ??
                        'So sánh ảnh của tôi',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (context) => const ComparisonView(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
    );
  }

  List photoArr = [
    // Không có ảnh mẫu - người dùng sẽ thêm ảnh của riêng họ
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          AppLocalizations.of(context)?.progressPhoto ?? "Progress Photo",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            onLongPress: () {
              // Long press để reset reminder
              _resetReminder();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.reminderReset ??
                        "Reminder reset!",
                  ),
                  duration: const Duration(seconds: 2),
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
                // Hiển thị reminder chỉ khi _showReminder = true
                if (_showReminder)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: const Color(0xffFFE5E5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: TColor.white,
                                borderRadius: BorderRadius.circular(30)),
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/img/date_notifi.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.reminder ??
                                        "Reminder!",
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    _reminderDescription(),
                                    style: TextStyle(
                                        color: TColor.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ]),
                          ),
                          Container(
                              height: 60,
                              alignment: Alignment.topRight,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showReminder = false;
                                    });
                                    _saveReminderState(false);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: TColor.gray,
                                    size: 15,
                                  )))
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _showTrackProgressOptions,
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
                          Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                            ?.trackYourProgress ??
                                        "Track Your Progress Each\nMonth With Photo",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 110,
                                    height: 35,
                                    child: RoundButton(
                                        icon: Icons.info_outline,
                                        iconSize: 16,
                                        onPressed: _showTrackProgressOptions),
                                  )
                                ]),
                          ),
                          Flexible(
                            child: Image.asset(
                              "assets/img/progress_each_photo.png",
                              width: media.width * 0.35,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)?.compareMyPhoto ??
                              "Compare my Photo",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 25,
                        child: RoundButton(
                          icon: Icons.compare_arrows,
                          iconSize: 16,
                          type: RoundButtonType.bgGradient,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ComparisonView(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.gallery ?? "Gallery",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      IconTextButton(
                        icon: Icons.arrow_forward,
                        iconSize: 18,
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: photoArr.length,
                    itemBuilder: ((context, index) {
                      var pObj = photoArr[index] as Map? ?? {};
                      var imaArr = pObj["photo"] as List? ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              pObj["time"].toString(),
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: imaArr.length,
                              itemBuilder: ((context, indexRow) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: TColor.lightGray,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      imaArr[indexRow] as String? ?? "",
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    }))
              ],
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SleepAddAlarmView(
          //       date: _selectedDateAppBBar,
          //     ),
          //   ),
          // );
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.photo_camera,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}
