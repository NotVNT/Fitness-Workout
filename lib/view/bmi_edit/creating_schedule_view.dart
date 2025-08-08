import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/colo_extension.dart';
import '../../providers/user_provider.dart';

class CreatingScheduleView extends StatefulWidget {
  final double height;
  final double currentWeight;
  final double targetWeight;
  final bool navigateToMainOnComplete;

  const CreatingScheduleView({
    super.key,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    this.navigateToMainOnComplete = false,
  });

  @override
  State<CreatingScheduleView> createState() => _CreatingScheduleViewState();
}

class _CreatingScheduleViewState extends State<CreatingScheduleView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.repeat();
    _saveDataAndNavigate();
  }

  Future<void> _saveDataAndNavigate() async {
    // Simulate creating schedule delay
    await Future.delayed(const Duration(seconds: 3));

    // Save data to Firebase
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateWeightHeightAndTarget(
      weight: widget.currentWeight,
      height: widget.height,
      targetWeight: widget.targetWeight,
    );

    if (success && mounted) {
      setState(() {
        _isCompleted = true;
      });

      // Wait a bit to show completion
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Nếu được khởi chạy từ Login, đi thẳng vào MainTabView, ngược lại chỉ pop về trước đó
        if (widget.navigateToMainOnComplete) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/main', (route) => false);
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật thông tin!'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading animation
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: TColor.primaryG,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform:
                            GradientRotation(_animation.value * 2 * 3.14159),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isCompleted ? Icons.check : Icons.fitness_center,
                        size: 50,
                        color:
                            _isCompleted ? Colors.green : TColor.primaryColor1,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                _isCompleted
                    ? "Hoàn thành!"
                    : "Đang tạo lịch biểu hằng ngày của bạn",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              // Subtitle
              if (!_isCompleted)
                Text(
                  "Vui lòng đợi trong giây lát...",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 60),

              // Progress dots
              if (!_isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        double delay = index * 0.3;
                        double animValue =
                            (_animationController.value - delay) % 1.0;
                        double opacity = animValue < 0.5
                            ? animValue * 2
                            : (1 - animValue) * 2;
                        opacity = opacity.clamp(0.3, 1.0);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                TColor.primaryColor1.withValues(alpha: opacity),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
