import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPhotoService {
  static const _prefsKey = 'progress_photos';

  /// Copy the picked image into an app-private, persistent folder and return the new path
  static Future<String> persistToAppDir(File sourceFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final sub = Directory('${dir.path}/progress_photos');
    if (!await sub.exists()) {
      await sub.create(recursive: true);
    }
    final ts = DateTime.now();
    final fileName =
        'photo_${ts.year}${_two(ts.month)}${_two(ts.day)}_${_two(ts.hour)}${_two(ts.minute)}${_two(ts.second)}.jpg';
    final target = File('${sub.path}/$fileName');
    return (await sourceFile.copy(target.path)).path;
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// Save a photo record with ISO date and file path
  static Future<void> addPhotoRecord({required DateTime date, required String path}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? <String>[];
    final record = jsonEncode({'date': date.toIso8601String(), 'path': path});
    list.add(record);
    await prefs.setStringList(_prefsKey, list);
  }

  static Future<List<Map<String, dynamic>>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? <String>[];
    return list
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .where((m) => m['path'] is String && m['date'] is String)
        .toList();
  }

  /// Get the latest photo path for the given month (year-month)
  static Future<String?> getLatestPhotoForMonth(DateTime month) async {
    final records = await getAllRecords();
    final sameMonth = records.where((m) {
      final d = DateTime.tryParse(m['date'] as String);
      return d != null && d.year == month.year && d.month == month.month;
    }).toList();
    if (sameMonth.isEmpty) return null;
    sameMonth.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return sameMonth.last['path'] as String;
  }
}

