import 'dart:convert';

class SleepSchedule {
  final int bedtimeHour; // 0-23
  final int bedtimeMinute; // 0-59
  final int sleepHours; // duration hours
  final int sleepMinutes; // duration minutes
  final bool vibrate;
  final String repeat; // e.g., "Mon-Fri" or "Everyday"

  SleepSchedule({
    required this.bedtimeHour,
    required this.bedtimeMinute,
    required this.sleepHours,
    required this.sleepMinutes,
    required this.vibrate,
    required this.repeat,
  });

  DateTime bedtimeOn(DateTime date) {
    return DateTime(date.year, date.month, date.day, bedtimeHour, bedtimeMinute);
  }

  DateTime wakeTimeOn(DateTime date) {
    return bedtimeOn(date).add(Duration(hours: sleepHours, minutes: sleepMinutes));
  }

  Map<String, dynamic> toMap() => {
        'bedtimeHour': bedtimeHour,
        'bedtimeMinute': bedtimeMinute,
        'sleepHours': sleepHours,
        'sleepMinutes': sleepMinutes,
        'vibrate': vibrate,
        'repeat': repeat,
      };

  static SleepSchedule fromMap(Map<String, dynamic> map) => SleepSchedule(
        bedtimeHour: map['bedtimeHour'] ?? 21,
        bedtimeMinute: map['bedtimeMinute'] ?? 0,
        sleepHours: map['sleepHours'] ?? 8,
        sleepMinutes: map['sleepMinutes'] ?? 30,
        vibrate: map['vibrate'] ?? true,
        repeat: map['repeat'] ?? 'Mon-Fri',
      );

  String toJson() => json.encode(toMap());
  static SleepSchedule fromJson(String source) => fromMap(json.decode(source));
}

