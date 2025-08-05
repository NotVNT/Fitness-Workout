import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../providers/user_provider.dart';
import 'current_weight_input_view.dart';

class HeightInputView extends StatefulWidget {
  const HeightInputView({super.key});

  @override
  State<HeightInputView> createState() => _HeightInputViewState();
}

class _HeightInputViewState extends State<HeightInputView> {
  double _selectedHeight = 170.0;
  bool _isMetric = true; // true for cm, false for ft
  final double _minHeight = 100.0;
  final double _maxHeight = 250.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null && userProvider.user!.height > 0) {
      _selectedHeight = userProvider.user!.height;
    }
  }

  void _onNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentWeightInputView(height: _selectedHeight),
      ),
    );
  }

  String _getDisplayHeight() {
    if (_isMetric) {
      return _selectedHeight.toInt().toString();
    } else {
      // Convert cm to feet and inches
      double totalInches = _selectedHeight / 2.54;
      int feet = (totalInches / 12).floor();
      int inches = (totalInches % 12).round();
      return "$feet'$inches\"";
    }
  }

  String _getDisplayUnit() {
    return _isMetric ? "cm" : "ft";
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
                  const SizedBox(height: 10),

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
                    "Chiều cao của bạn là bao nhiêu?",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "Điều này giúp chúng tôi tạo ra kế hoạch cá nhân hóa cho bạn",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

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
                              "cm",
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
                              "ft",
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

                  const SizedBox(height: 40),

                  // Height display
                  Text(
                    _getDisplayHeight(),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _getDisplayUnit(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Height slider
                  SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        // Scale marks on the right
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 50,
                          child: CustomPaint(
                            painter: HeightScalePainter(
                              minHeight: _minHeight,
                              maxHeight: _maxHeight,
                              selectedHeight: _selectedHeight,
                              isMetric: _isMetric,
                            ),
                          ),
                        ),
                        // Slider
                        Positioned(
                          left: 20,
                          right: 60,
                          top: 0,
                          bottom: 0,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              activeTrackColor: TColor.primaryColor1,
                              inactiveTrackColor: TColor.lightGray,
                              thumbColor: TColor.primaryColor1,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 10),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 16),
                            ),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: _selectedHeight,
                                min: _minHeight,
                                max: _maxHeight,
                                divisions: (_maxHeight - _minHeight).toInt(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedHeight = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

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

class HeightScalePainter extends CustomPainter {
  final double minHeight;
  final double maxHeight;
  final double selectedHeight;
  final bool isMetric;

  HeightScalePainter({
    required this.minHeight,
    required this.maxHeight,
    required this.selectedHeight,
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

    // Draw scale marks every 20 units (less crowded for smaller height)
    for (int i = minHeight.toInt(); i <= maxHeight.toInt(); i += 20) {
      final progress = (i - minHeight) / (maxHeight - minHeight);
      final y = size.height - (progress * size.height);

      // Draw tick mark
      canvas.drawLine(
        Offset(0, y),
        Offset(15, y), // Shorter marks for compact design
        paint,
      );

      // Draw text for all marks
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: TColor.gray,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(20, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
