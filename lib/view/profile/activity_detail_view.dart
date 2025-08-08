import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';

class ActivityDetailView extends StatelessWidget {
  final Map<String, dynamic> a;
  const ActivityDetailView({super.key, required this.a});

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return d;
    }
  }

  String _typeVi(String t) {
    switch (t) {
      case 'workout':
        return 'Tập luyện';
      case 'meal':
        return 'Bữa ăn';
      case 'sleep':
        return 'Giấc ngủ';
      default:
        return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(a['type'] as String?);

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.black),
        title: Text('Chi tiết hoạt động', style: TextStyle(color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon((a['icon'] as IconData?) ?? Icons.info_outline, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((a['title'] as String?) ?? '-', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text((a['subtitle'] as String?) ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            _InfoRow(label: 'Loại', value: _typeVi((a['type'] as String?) ?? '-')),
            _InfoRow(label: 'Ngày', value: _formatDate((a['date'] as String?) ?? '-')),
            if (a['kcal'] != null) _InfoRow(label: 'Năng lượng', value: '${a['kcal']} kcal'),
            if (a['minutes'] != null) _InfoRow(label: 'Thời lượng', value: '${a['minutes']} phút'),
            const SizedBox(height: 24),
            Text('Ghi chú', style: TextStyle(color: TColor.black, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              (a['note'] as String?) ?? 'Không có ghi chú.',
              style: TextStyle(color: TColor.gray, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String? t) {
    switch (t) {
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: TColor.lightGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: TColor.gray, fontSize: 13))),
          Expanded(child: Text(value, style: TextStyle(color: TColor.black, fontSize: 13))),
        ],
      ),
    );
  }
}

