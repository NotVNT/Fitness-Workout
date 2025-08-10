import 'package:fitness/common_widget/icon_title_next_row.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/view/photo_progress/result_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/colo_extension.dart';
import '../../l10n/app_localizations.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  DateTime? _month1 = DateTime.now();
  DateTime? _month2;

  String _fmtMonth(DateTime? d) {
    final locale = Localizations.localeOf(context).languageCode;
    if (d == null) return AppLocalizations.of(context)?.selectMonth ?? 'Select Month';
    return DateFormat('MMMM', locale).format(d);
  }

  Future<void> _pickMonth({required int which}) async {
    final now = DateTime.now();
    final initial = (which == 1 ? _month1 : _month2) ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: AppLocalizations.of(context)?.selectMonthHelp ?? 'Select month',
    );

    if (picked != null) {
      setState(() {
        final monthOnly = DateTime(picked.year, picked.month, 1);
        if (which == 1) {
          _month1 = monthOnly;
        } else {
          _month2 = monthOnly;
        }
      });
    }
  }

  void _onCompare() {
    if (_month1 == null || _month2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.pleaseSelectTwoMonths ?? 'Please select two months to compare.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultView(
          date1: _month1!,
          date2: _month2!,
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
                title: AppLocalizations.of(context)?.selectMonth1 ?? "Select Month 1",
                time: _fmtMonth(_month1),
                onPressed: () => _pickMonth(which: 1),
                color: TColor.lightGray),
            const SizedBox(
              height: 15,
            ),
            IconTitleNextRow(
                icon: "assets/img/date.png",
                title: AppLocalizations.of(context)?.selectMonth2 ?? "Select Month 2",
                time: _fmtMonth(_month2),
                onPressed: () => _pickMonth(which: 2),
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
