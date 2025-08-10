import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local activity log for user actions inside the app (not workout logs)
/// Each event keeps: id, ts (ISO), type, title, subtitle, extra(optional)
class ActivityLogService {
  static const _key = 'activity_log_v1';

  /// Append a generic event
  static Future<void> addEvent({
    required String type,
    required String title,
    String? subtitle,
    Map<String, dynamic>? extra,
    DateTime? when,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    final ts = (when ?? DateTime.now()).toIso8601String();
    final id = '${DateTime.now().millisecondsSinceEpoch}_${list.length}';
    final record = jsonEncode({
      'id': id,
      'ts': ts,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'extra': extra,
    });
    list.add(record);
    await prefs.setStringList(_key, list);
  }

  /// Return all events, newest first
  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    final decoded = list
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .where((m) => m['ts'] is String && m['type'] is String)
        .toList();
    decoded.sort((a, b) => (b['ts'] as String).compareTo(a['ts'] as String));
    return decoded;
  }

  /// Utilities for common actions
  static Future<void> logPhotoCaptured(String path) => addEvent(
        type: 'photo',
        title: 'Đã chụp ảnh tiến độ',
        subtitle: 'Đường dẫn: $path',
        extra: {'path': path},
      );

  static Future<void> logPhotosCompared(String p1, String p2) => addEvent(
        type: 'photo',
        title: 'So sánh 2 ảnh tiến độ',
        subtitle: 'Ảnh 1 và Ảnh 2',
        extra: {'p1': p1, 'p2': p2},
      );

  static Future<void> logNotificationsCleared(int count) => addEvent(
        type: 'notification',
        title: 'Xóa tất cả thông báo',
        subtitle: '$count thông báo',
        extra: {'count': count},
      );

  static Future<void> logNotificationDeleted(String? title) => addEvent(
        type: 'notification',
        title: 'Xóa một thông báo',
        subtitle: title,
      );

  static Future<void> logReminderSet(TimeOfDay time) => addEvent(
        type: 'settings',
        title: 'Đặt giờ nhắc tập luyện',
        subtitle: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      );

  /// Clear all events (not used by UI yet)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

