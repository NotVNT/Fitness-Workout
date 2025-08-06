import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../providers/user_provider.dart';
import 'creating_schedule_view.dart';

class TargetWeightInputView extends StatefulWidget {
  final double height;
  final double currentWeight;

  const TargetWeightInputView({
    super.key,
    required this.height,
    required this.currentWeight,
  });

  @override
  State<TargetWeightInputView> createState() => _TargetWeightInputViewState();
}

class _TargetWeightInputViewState extends State<TargetWeightInputView> {
  double _selectedTargetWeight = 70.0;
  bool _isMetric = true; // true for kg, false for lb
  final double _minWeight = 30.0;
  final double _maxWeight = 250.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null && userProvider.user!.targetWeight > 0) {
      _selectedTargetWeight = userProvider.user!.targetWeight;
    } else {
      // Set default target weight slightly less than current weight
      _selectedTargetWeight = widget.currentWeight - 5;
      if (_selectedTargetWeight < _minWeight) {
        _selectedTargetWeight = _minWeight;
      }
    }
  }

  void _onNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatingScheduleView(
          height: widget.height,
          currentWeight: widget.currentWeight,
          targetWeight: _selectedTargetWeight,
        ),
      ),
    );
  }

  String _getDisplayWeight() {
    if (_isMetric) {
      return _selectedTargetWeight.toStringAsFixed(1);
    } else {
      // Convert kg to lb
      double weightInLb = _selectedTargetWeight * 2.20462;
      return weightInLb.toStringAsFixed(1);
    }
  }

  String _getDisplayUnit() {
    return _isMetric ? "kg" : "lb";
  }

  double _calculateTargetBMI() {
    double heightInM = widget.height / 100; // Convert cm to meters
    return _selectedTargetWeight / (heightInM * heightInM);
  }

  String _getTargetBMIAdvice() {
    double bmi = _calculateTargetBMI();
    if (bmi < 18.5) return "Mục tiêu này có thể quá thấp cho sức khỏe";
    if (bmi < 25) return "Mục tiêu tuyệt vời cho sức khỏe!";
    if (bmi < 30) return "Mục tiêu tốt, hãy cố gắng đạt được";
    return "Hãy đặt mục tiêu thấp hơn để an toàn";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),

                  // Back button
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: TColor.lightGray,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: TColor.black,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    "Cân nặng mục tiêu của bạn là bao nhiêu?",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Điều này giúp chúng tôi tạo ra kế hoạch cá nhân hóa cho bạn",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // Unit selector
                  Container(
                    decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isMetric = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isMetric
                                  ? TColor.primaryColor1
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "kg",
                              style: TextStyle(
                                color: _isMetric ? TColor.white : TColor.gray,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isMetric = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isMetric
                                  ? TColor.primaryColor1
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "lb",
                              style: TextStyle(
                                color: !_isMetric ? TColor.white : TColor.gray,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Weight display
                  Text(
                    _getDisplayWeight(),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _getDisplayUnit(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Weight slider with scale
                  SizedBox(
                    height: 80,
                    child: Stack(
                      children: [
                        // Scale marks
                        Positioned.fill(
                          child: CustomPaint(
                            painter: WeightScalePainter(
                              minWeight: _minWeight,
                              maxWeight: _maxWeight,
                              selectedWeight: _selectedTargetWeight,
                              isMetric: _isMetric,
                            ),
                          ),
                        ),
                        // Slider
                        Positioned.fill(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              activeTrackColor: TColor.primaryColor1,
                              inactiveTrackColor: TColor.lightGray,
                              thumbColor: TColor.primaryColor1,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 12),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 20),
                            ),
                            child: Slider(
                              value: _selectedTargetWeight,
                              min: _minWeight,
                              max: _maxWeight,
                              divisions: ((_maxWeight - _minWeight) * 2)
                                  .toInt(), // 0.5 increments
                              onChanged: (value) {
                                setState(() {
                                  _selectedTargetWeight = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Target BMI Display
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "BMI Mục tiêu của bạn",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.info_outline,
                              color: TColor.gray,
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _calculateTargetBMI().toStringAsFixed(1),
                              style: TextStyle(
                                color: TColor.primaryColor1,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getTargetBMIAdvice(),
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Next button
                  RoundButton(
                    title: "Tiếp theo",
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeightScalePainter extends CustomPainter {
  final double minWeight;
  final double maxWeight;
  final double selectedWeight;
  final bool isMetric;

  WeightScalePainter({
    required this.minWeight,
    required this.maxWeight,
    required this.selectedWeight,
    required this.isMetric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TColor.gray
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw scale marks every 10 units for kg, every 20 for lb
    int step = isMetric ? 10 : 20;
    int majorStep = isMetric ? 20 : 40;

    for (int i = minWeight.toInt(); i <= maxWeight.toInt(); i += step) {
      final progress = (i - minWeight) / (maxWeight - minWeight);
      final x = progress * size.width;

      // Draw tick mark
      canvas.drawLine(
        Offset(x, size.height - 15),
        Offset(x, size.height - (i % majorStep == 0 ? 30 : 22)),
        paint,
      );

      // Draw text for major marks
      if (i % majorStep == 0) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: TColor.gray,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        textPainter.paint(
            canvas, Offset(x - textPainter.width / 2, size.height - 12));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
