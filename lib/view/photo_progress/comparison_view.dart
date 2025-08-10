import 'package:fitness/common_widget/icon_title_next_row.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/view/photo_progress/result_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../common/colo_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../services/progress_photo_service.dart';
import '../../services/activity_log_service.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  Map<String, dynamic>? _photo1; // {date: DateTime, path: String}
  Map<String, dynamic>? _photo2;
  List<Map<String, dynamic>> _all = [];

  String _fmtPhotoLabel(Map<String, dynamic>? p) {
    if (p == null) return 'Chọn ảnh';
    final d = p['date'] as DateTime?;
    final locale = Localizations.localeOf(context).languageCode;
    if (d == null) return 'Đã chọn';
    return DateFormat('dd/MM/yyyy', locale).format(d);
  }

  Future<void> _ensureLoaded() async {
    if (_all.isNotEmpty) return;
    final recs = await ProgressPhotoService.getAllRecords();
    _all = recs.map((m) {
      final d = DateTime.tryParse(m['date'] as String);
      return {
        'date': d,
        'path': m['path'] as String,
      };
    }).where((m) => m['date'] != null).cast<Map<String, dynamic>>().toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  }

  Future<void> _pickPhoto({required int which}) async {
    await _ensureLoaded();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: _all.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Chưa có ảnh nào. Hãy chụp ảnh trước.'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: _all.length,
                  itemBuilder: (_, i) {
                    final p = _all[i];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (which == 1) {
                            _photo1 = p;
                          } else {
                            _photo2 = p;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(p['path'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _onCompare() async {
    if (_photo1 == null || _photo2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đủ 2 ảnh.')),
      );
      return;
    }
    if (_photo1!['path'] == _photo2!['path']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn 2 ảnh khác nhau.')),
      );
      return;
    }

    final d1 = (_photo1!['date'] as DateTime);
    final d2 = (_photo2!['date'] as DateTime);

    if (!mounted) return;
    // Log user action
    await ActivityLogService.logPhotosCompared(_photo1!['path'] as String, _photo2!['path'] as String);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultView(
          date1: DateTime(d1.year, d1.month, 1),
          date2: DateTime(d2.year, d2.month, 1),
          photo1Path: _photo1!['path'] as String,
          photo2Path: _photo2!['path'] as String,
        ),
      ),
    );
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
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)?.comparison ?? "Comparison",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            IconTitleNextRow(
                icon: "assets/img/date.png",
                title: 'Chọn ảnh 1',
                time: _fmtPhotoLabel(_photo1),
                onPressed: () => _pickPhoto(which: 1),
                color: TColor.lightGray),
            const SizedBox(
              height: 15,
            ),
            IconTitleNextRow(
                icon: "assets/img/date.png",
                title: 'Chọn ảnh 2',
                time: _fmtPhotoLabel(_photo2),
                onPressed: () => _pickPhoto(which: 2),
                color: TColor.lightGray),
            const Spacer(),
            RoundButton(
              icon: Icons.compare_arrows,
              iconSize: 20,
              onPressed: _onCompare,
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
