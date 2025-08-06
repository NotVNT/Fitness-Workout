import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../providers/user_provider.dart';
import '../../l10n/app_localizations.dart';

class BMIEditDialog extends StatefulWidget {
  const BMIEditDialog({super.key});

  @override
  State<BMIEditDialog> createState() => _BMIEditDialogState();
}

class _BMIEditDialogState extends State<BMIEditDialog> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _currentBMI = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      _weightController.text = userProvider.user!.weight > 0
          ? userProvider.user!.weight.toString()
          : '';
      _heightController.text = userProvider.user!.height > 0
          ? userProvider.user!.height.toString()
          : '';
      _calculateBMI();
    }
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final height = double.tryParse(_heightController.text) ?? 0.0;

    if (weight > 0 && height > 0) {
      final heightInMeters = height / 100;
      setState(() {
        _currentBMI = weight / (heightInMeters * heightInMeters);
      });
    } else {
      setState(() {
        _currentBMI = 0.0;
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi == 0.0) return 'Chưa có thông tin';
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  Color _getBMIColor(double bmi) {
    if (bmi == 0.0) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateWeightAndHeight(
      weight: weight,
      height: height,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.bmiUpdateSuccess ??
                'Cập nhật thông tin BMI thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.bmiUpdateError ??
                'Có lỗi xảy ra khi cập nhật thông tin!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                AppLocalizations.of(context)?.editBMIInfo ??
                    'Chỉnh sửa thông tin BMI',
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              // Weight input
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateBMI(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.pleaseEnterWeight ??
                          'Vui lòng nhập cân nặng';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0 || weight > 500) {
                      return AppLocalizations.of(context)?.invalidWeight ??
                          'Cân nặng không hợp lệ (1-500 kg)';
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: AppLocalizations.of(context)?.weightKg ??
                        "Cân nặng (kg)",
                    hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
                    prefixIcon: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      child: Icon(Icons.monitor_weight, color: TColor.gray),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Height input
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateBMI(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.pleaseEnterHeight ??
                          'Vui lòng nhập chiều cao';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height <= 0 || height > 300) {
                      return AppLocalizations.of(context)?.invalidHeight ??
                          'Chiều cao không hợp lệ (1-300 cm)';
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: AppLocalizations.of(context)?.heightCm ??
                        "Chiều cao (cm)",
                    hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
                    prefixIcon: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      child: Icon(Icons.height, color: TColor.gray),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // BMI Display
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _getBMIColor(_currentBMI).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _getBMIColor(_currentBMI),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.currentBMI ??
                          'BMI hiện tại',
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currentBMI > 0 ? _currentBMI.toStringAsFixed(1) : '--',
                      style: TextStyle(
                        color: _getBMIColor(_currentBMI),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getBMICategory(_currentBMI),
                      style: TextStyle(
                        color: _getBMIColor(_currentBMI),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: RoundButton(
                      title: AppLocalizations.of(context)?.cancel ?? "Hủy",
                      type: RoundButtonType.textGradient,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _isLoading
                        ? Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)?.saving ??
                                    "Đang lưu...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : RoundButton(
                            title: AppLocalizations.of(context)?.save ?? "Lưu",
                            type: RoundButtonType.bgGradient,
                            onPressed: () {
                              _saveChanges();
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
