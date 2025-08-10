import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/language_selector.dart';
import '../../l10n/app_localizations.dart';
import '../../services/workout_reminder_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _pushEnabled = true;
  TimeOfDay? _workoutReminder;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final res = await WorkoutReminderService.load();
    if (!mounted) return;
    setState(() {
      _workoutReminder = res == null ? null : TimeOfDay(hour: res.h, minute: res.m);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.black),
        title: Text(
          AppLocalizations.of(context)?.settings ?? 'Cài đặt',
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notification section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.notification ?? 'Thông báo',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/img/p_notification.png',
                          height: 15,
                          width: 15,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _workoutReminder ?? const TimeOfDay(hour: 7, minute: 0),
                              );
                              if (picked != null) {
                                await WorkoutReminderService.save(picked.hour, picked.minute);
                                if (!mounted) return;
                                setState(() => _workoutReminder = picked);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Chọn giờ tập luyện thành công: ${picked.format(context)}')),
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.popUpNotification ?? 'Giờ tập luyện',
                                  style: TextStyle(color: TColor.black, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                                if (_workoutReminder != null)
                                  Text(
                                    _workoutReminder!.format(context),
                                    style: TextStyle(
                                      color: TColor.primaryColor2,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Switch(
                          value: _pushEnabled,
                          onChanged: (v) => setState(() => _pushEnabled = v),
                          activeColor: TColor.white,
                          activeTrackColor: TColor.primaryColor2,
                          inactiveThumbColor: TColor.white,
                          inactiveTrackColor: TColor.gray.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Language section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
              child: const LanguageSelector(),
            ),
          ],
        ),
      ),
    );
  }
}

