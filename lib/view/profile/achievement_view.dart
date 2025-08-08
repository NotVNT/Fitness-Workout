import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../l10n/app_localizations.dart';

class AchievementView extends StatefulWidget {
  const AchievementView({super.key});

  @override
  State<AchievementView> createState() => _AchievementViewState();
}

class _AchievementViewState extends State<AchievementView> {
  int _selectedTab = 0; // 0: All, 1: Earned, 2: In progress

  // Demo achievements. Later can be replaced with real data from Firestore.
  final List<Map<String, dynamic>> _achievements = [
    {
      'icon': Icons.emoji_events_rounded,
      'title': 'Khởi đầu tuyệt vời',
      'desc': 'Hoàn thành buổi tập đầu tiên',
      'earned': true,
      'date': 'Hôm nay',
      'progress': 1.0,
      'colors': [TColor.primaryColor2, TColor.primaryColor1],
    },
    {
      'icon': Icons.local_fire_department_rounded,
      'title': 'Đốt 1.000 kcal',
      'desc': 'Tổng số kcal đốt cháy đạt 1.000',
      'earned': false,
      'date': null,
      'progress': 0.45,
      'colors': [TColor.secondaryColor2, TColor.secondaryColor1],
    },
    {
      'icon': Icons.calendar_today_rounded,
      'title': 'Chuỗi 7 ngày',
      'desc': 'Tập luyện liên tục 7 ngày',
      'earned': false,
      'date': null,
      'progress': 0.6,
      'colors': [TColor.primaryColor2, TColor.secondaryColor1],
    },
    {
      'icon': Icons.directions_run_rounded,
      'title': '100.000 bước chân',
      'desc': 'Tổng cộng 100.000 bước',
      'earned': true,
      'date': 'Tuần trước',
      'progress': 1.0,
      'colors': [TColor.secondaryColor2, TColor.primaryColor1],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final earnedCount = _achievements.where((e) => e['earned'] == true).length;

    final filtered = _achievements.where((a) {
      if (_selectedTab == 1) return a['earned'] == true;
      if (_selectedTab == 2) return a['earned'] == false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.black),
        title: Text(
          AppLocalizations.of(context)?.achievement ?? 'Achievement',
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _HeaderSummary(total: _achievements.length, earned: earnedCount),
          const SizedBox(height: 12),
          _Tabs(
            selected: _selectedTab,
            onChanged: (i) => setState(() => _selectedTab = i),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemBuilder: (context, index) {
                final a = filtered[index];
                return _AchievementCard(
                  icon: a['icon'] as IconData,
                  title: a['title'] as String,
                  desc: a['desc'] as String,
                  earned: a['earned'] as bool,
                  date: a['date'] as String?,
                  progress: (a['progress'] as num).toDouble(),
                  colors: (a['colors'] as List<Color>),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: filtered.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  final int total;
  final int earned;
  const _HeaderSummary({required this.total, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryColor1.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng số thành tích: $total',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Đã đạt: $earned',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _Tabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int idx) {
      final isSelected = idx == selected;
      return InkWell(
        onTap: () => onChanged(idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? null : TColor.lightGray,
            gradient: isSelected ? LinearGradient(colors: TColor.secondaryG) : null,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : TColor.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          chip('Tất cả', 0),
          const SizedBox(width: 8),
          chip('Đã đạt', 1),
          const SizedBox(width: 8),
          chip('Đang tiến trình', 2),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool earned;
  final String? date;
  final double progress;
  final List<Color> colors;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.earned,
    required this.date,
    required this.progress,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (earned)
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Đã đạt', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: TColor.gray, fontSize: 12)),
                const SizedBox(height: 10),
                _ProgressBar(value: progress, earned: earned),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(color: TColor.gray, fontSize: 11),
                    ),
                    Text(
                      earned ? (date ?? '') : 'Đang cố gắng...',
                      style: TextStyle(color: TColor.gray, fontSize: 11),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final bool earned;
  const _ProgressBar({required this.value, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: TColor.lightGray,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth * value.clamp(0.0, 1.0);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              width: w,
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: earned ? TColor.primaryG : TColor.secondaryG),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
      ],
    );
  }
}

