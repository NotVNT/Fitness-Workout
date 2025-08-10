import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../common/colo_extension.dart';

class ActivityProgressChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels; // length should match values
  final List<List<Color>>? gradients; // optional per-bar gradients
  final double maxY;
  final double barWidth;

  const ActivityProgressChart({
    super.key,
    required this.values,
    required this.labels,
    this.gradients,
    this.maxY = 20,
    this.barWidth = 22,
  });

  @override
  State<ActivityProgressChart> createState() => _ActivityProgressChartState();
}

class _ActivityProgressChartState extends State<ActivityProgressChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.grey,
            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
            tooltipMargin: 10,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label;
              final x = group.x.toInt();
              if (x >= 0 && x < widget.labels.length) {
                label = widget.labels[x];
              } else {
                label = 'Day ${group.x}';
              }
              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    // Keep previous behavior: when touched, rod.toY = y + 1
                    text: (rod.toY - 1).toString(),
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' lần'),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _getTitles,
              reservedSize: 38,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildGroups(),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: TColor.gray,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    final idx = value.toInt();
    final label = (idx >= 0 && idx < widget.labels.length) ? widget.labels[idx] : '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(label, style: style),
    );
  }

  List<BarChartGroupData> _buildGroups() {
    return List.generate(widget.values.length, (i) {
      final y = widget.values[i];
      final gradient = (widget.gradients != null && i < widget.gradients!.length)
          ? widget.gradients![i]
          : (i % 2 == 0 ? TColor.primaryG : TColor.secondaryG);

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: i == touchedIndex ? y + 1 : y,
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: widget.barWidth,
            borderSide: i == touchedIndex
                ? const BorderSide(color: Colors.green)
                : const BorderSide(color: Colors.white, width: 0),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: widget.maxY,
              color: TColor.lightGray,
            ),
          ),
        ],
        showingTooltipIndicators: const [],
      );
    });
  }
}

