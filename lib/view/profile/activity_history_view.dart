import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../services/activity_log_service.dart';
import 'activity_detail_view.dart';

class ActivityHistoryView extends StatefulWidget {
  const ActivityHistoryView({super.key});

  @override
  State<ActivityHistoryView> createState() => _ActivityHistoryViewState();
}

class _ActivityHistoryViewState extends State<ActivityHistoryView> {
  int _selectedFilter = 0; // 0: All, 1: Notification, 2: Photo, 3: Settings

  // Data model to render (already mapped from raw logs)
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await ActivityLogService.getAll();
    if (!mounted) return;
    setState(() {
      _activities = logs.map<Map<String, dynamic>>((m) {
        final ts = (m['ts'] as String?) ?? DateTime.now().toIso8601String();
        final date = ts.substring(0, 10);
        final type = (m['type'] as String?) ?? 'other';
        final icon = _iconForType(type);
        return {
          'date': date,
          'type': type,
          'title': (m['title'] as String?) ?? '-',
          'subtitle': (m['subtitle'] as String?) ?? '',
          'icon': icon,
          'ts': ts,
        };
      }).toList();
    });
  }

  static IconData _iconForType(String t) {
    switch (t) {
      case 'notification':
        return Icons.notifications_rounded;
      case 'photo':
        return Icons.photo_camera_rounded;
      case 'settings':
        return Icons.settings_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Filtering
    final filtered = _activities.where((a) {
      switch (_selectedFilter) {
        case 1:
          return a['type'] == 'notification';
        case 2:
          return a['type'] == 'photo';
        case 3:
          return a['type'] == 'settings';
        default:
          return true;
      }
    }).toList();

    // Group by date
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final a in filtered) {
      final d = a['date'] as String;
      grouped.putIfAbsent(d, () => []).add(a);
    }
    final dates = grouped.keys.toList()..sort((b, a) => a.compareTo(b));

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.black),
        title: Text(
          loc?.activityHistory ?? 'Activity History',
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          _SummaryHeader(activities: filtered),
          const SizedBox(height: 12),
          _FilterChips(
            selected: _selectedFilter,
            onChanged: (i) => setState(() => _selectedFilter = i),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final list = grouped[date]!;
                return _DateSection(date: date, items: list);
              },
            ),
          )
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  const _SummaryHeader({required this.activities});

  @override
  Widget build(BuildContext context) {
    final photoCount = activities.where((a) => a['type'] == 'photo').length;
    final notiCount = activities.where((a) => a['type'] == 'notification').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryColor1.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.event_available_rounded,
              label: (Localizations.localeOf(context).languageCode == 'en') ? 'Activities' : 'Hoạt động',
              value: activities.length.toString(),
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.photo_library_rounded,
              label: (Localizations.localeOf(context).languageCode == 'en') ? 'Photos' : 'Ảnh',
              value: photoCount.toString(),
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.notifications_rounded,
              label: (Localizations.localeOf(context).languageCode == 'en') ? 'Notifications' : 'Thông báo',
              value: notiCount.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int idx) {
      final isSelected = idx == selected;
      return InkWell(
        onTap: () => onChanged(idx),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? null : TColor.lightGray,
            gradient:
                isSelected ? LinearGradient(colors: TColor.secondaryG) : null,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: isSelected ? Colors.white : TColor.black,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            chip(Localizations.localeOf(context).languageCode == 'en' ? 'All' : 'Tất cả', 0),
            chip(Localizations.localeOf(context).languageCode == 'en' ? 'Notifications' : 'Thông báo', 1),
            chip(Localizations.localeOf(context).languageCode == 'en' ? 'Photos' : 'Ảnh', 2),
            chip(Localizations.localeOf(context).languageCode == 'en' ? 'Settings' : 'Cài đặt', 3),
          ],
        ),
      ),
    );
  }
}

class _DateSection extends StatelessWidget {
  final String date; // yyyy-mm-dd
  final List<Map<String, dynamic>> items;
  const _DateSection({required this.date, required this.items});

  String _format(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(_format(date),
            style: TextStyle(
                color: TColor.gray, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...items.map((a) => _HistoryItem(a: a)),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> a;
  const _HistoryItem({required this.a});

  Color _typeColor() {
    switch (a['type']) {
      case 'notification':
        return Colors.orange;
      case 'photo':
        return Colors.purple;
      case 'settings':
        return Colors.indigo;
      default:
        return TColor.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailView(a: a)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _typeColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(a['icon'] as IconData, color: _typeColor()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a['title'] as String,
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(a['subtitle'] as String,
                      style: TextStyle(color: TColor.gray, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
