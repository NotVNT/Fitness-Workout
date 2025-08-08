import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../l10n/app_localizations.dart';
import 'activity_detail_view.dart';

class ActivityHistoryView extends StatefulWidget {
  const ActivityHistoryView({super.key});

  @override
  State<ActivityHistoryView> createState() => _ActivityHistoryViewState();
}

class _ActivityHistoryViewState extends State<ActivityHistoryView> {
  int _selectedFilter = 0; // 0: All, 1: Workout, 2: Meal, 3: Sleep

  // Demo activity data; can be replaced with real user history later.
  // date: yyyy-mm-dd for grouping.
  final List<Map<String, dynamic>> _activities = [
    {
      'date': '2025-08-08',
      'type': 'workout',
      'title': 'Tập toàn thân',
      'subtitle': '320 kcal • 25 phút',
      'icon': Icons.fitness_center,
      'kcal': 320,
      'minutes': 25,
    },
    {
      'date': '2025-08-08',
      'type': 'meal',
      'title': 'Bữa trưa lành mạnh',
      'subtitle': 'Protein cao • 560 kcal',
      'icon': Icons.restaurant,
    },
    {
      'date': '2025-08-07',
      'type': 'workout',
      'title': 'Yoga phục hồi',
      'subtitle': '120 kcal • 40 phút',
      'icon': Icons.self_improvement,
      'kcal': 120,
      'minutes': 40,
    },
    {
      'date': '2025-08-07',
      'type': 'sleep',
      'title': 'Giấc ngủ đêm',
      'subtitle': '7 giờ 45 phút',
      'icon': Icons.nightlight_round,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Filtering
    final filtered = _activities.where((a) {
      switch (_selectedFilter) {
        case 1:
          return a['type'] == 'workout';
        case 2:
          return a['type'] == 'meal';
        case 3:
          return a['type'] == 'sleep';
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
    final workouts = activities.where((a) => a['type'] == 'workout');
    final kcal =
        workouts.fold<int>(0, (sum, a) => sum + (a['kcal'] as int? ?? 0));
    final mins =
        workouts.fold<int>(0, (sum, a) => sum + (a['minutes'] as int? ?? 0));

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
              icon: Icons.local_fire_department_rounded,
              label: 'Kcal',
              value: kcal.toString(),
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.timer_rounded,
              label: 'Phút',
              value: mins.toString(),
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.event_available_rounded,
              label: 'Hoạt động',
              value: activities.length.toString(),
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
            chip('Tất cả', 0),
            chip('Tập luyện', 1),
            chip('Bữa ăn', 2),
            chip('Giấc ngủ', 3),
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
      case 'workout':
        return TColor.primaryColor1;
      case 'meal':
        return TColor.secondaryColor1;
      case 'sleep':
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
