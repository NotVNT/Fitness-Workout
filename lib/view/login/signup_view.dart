import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';
import 'package:fitness/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:fitness/services/auth_service.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  // Kiểm tra mật khẩu mạnh
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;

    // Kiểm tra có chữ hoa
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Kiểm tra có chữ thường
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Kiểm tra có số
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    return true;
  }

  // Lấy thông báo lỗi mật khẩu
  String _getPasswordErrorMessage(String password) {
    List<String> errors = [];

    if (password.length < 8) {
      errors.add('ít nhất 8 ký tự');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('ít nhất 1 chữ hoa');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('ít nhất 1 chữ thường');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('ít nhất 1 số');
    }

    return 'Mật khẩu phải có: ${errors.join(', ')}';
  }

  // Method để chọn ngày sinh
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
          .subtract(const Duration(days: 365 * 13)), // Tối thiểu 13 tuổi
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.primaryColor1,
              onPrimary: TColor.white,
              surface: TColor.white,
              onSurface: TColor.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _signUp() async {
    // Validation
    if (_firstNameController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập họ');
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập tên');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập email');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập mật khẩu');
      return;
    }
    if (!_isPasswordStrong(_passwordController.text)) {
      _showErrorMessage(_getPasswordErrorMessage(_passwordController.text));
      return;
    }
    if (_confirmPasswordController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng xác nhận mật khẩu');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('Mật khẩu xác nhận không khớp');
      return;
    }
    if (_selectedDate == null) {
      _showErrorMessage('Vui lòng chọn ngày sinh');
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showErrorMessage('Vui lòng nhập số điện thoại');
      return;
    }
    // Mẫu VN: 0xxxxxxxxx hoặc +84xxxxxxxxx, đầu số 3/5/7/8/9
    final vnPhoneRegex = RegExp(r'^(0|\+?84)(3|5|7|8|9)\d{8}$');
    if (!vnPhoneRegex.hasMatch(phone)) {
      _showErrorMessage('Số điện thoại không hợp lệ');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
      );

      if (result != null) {
        // Đăng ký thành công, đăng xuất và chuyển đến màn hình đăng nhập
        _showSuccessMessage('Đăng ký thành công!');

        // Đăng xuất user vừa tạo để họ phải đăng nhập lại
        await _authService.signOut();

        // Delay một chút để user đọc thông báo
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Chuyển đến màn hình đăng nhập
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginView(),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorMessage(_authService.getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  bool isCheck = false;
  bool _isPasswordVisible = false; // Thêm biến để quản lý hiện/ẩn mật khẩu
  bool _isConfirmPasswordVisible =
      false; // Thêm biến để quản lý hiện/ẩn mật khẩu xác nhận

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Xin chào,",
                  style: TextStyle(color: TColor.gray, fontSize: 16),
                ),
                Text(
                  "Tạo tài khoản",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                RoundTextField(
                  hitText: "Tên",
                  icon: "assets/img/user_text.png",
                  controller: _firstNameController,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Họ",
                  icon: "assets/img/user_text.png",
                  controller: _lastNameController,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                // Phone number (Vietnam)
                RoundTextField(
                  hitText: "Số điện thoại",
                  icon: "assets/img/p_contact.png",
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                // Date of Birth field
                GestureDetector(
                  onTap: _selectDateOfBirth,
                  child: AbsorbPointer(
                    child: RoundTextField(
                      hitText: "Ngày sinh (dd/mm/yyyy)",
                      icon: "assets/img/date.png",
                      controller: _dateOfBirthController,
                      rigtIcon: TextButton(
                        onPressed: _selectDateOfBirth,
                        child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.calendar_today,
                            color: TColor.gray,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Email",
                  icon: "assets/img/email.png",
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Mật khẩu",
                  icon: "assets/img/lock.png",
                  obscureText: !_isPasswordVisible,
                  controller: _passwordController,
                  rigtIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: TColor.gray,
                            size: 20,
                          ))),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Xác nhận mật khẩu",
                  icon: "assets/img/lock.png",
                  obscureText: !_isConfirmPasswordVisible,
                  controller: _confirmPasswordController,
                  rigtIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: TColor.gray,
                            size: 20,
                          ))),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isCheck = !isCheck;
                        });
                      },
                      icon: Icon(
                        isCheck
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank_outlined,
                        color: TColor.gray,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Bằng cách tiếp tục, bạn đồng ý với Chính sách bảo mật\nvà Điều khoản sử dụng của chúng tôi",
                          style: TextStyle(color: TColor.gray, fontSize: 10),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.4,
                ),
                RoundButton(
                    title: _isLoading ? "Đang đăng ký..." : "Đăng ký",
                    onPressed: _isLoading ? () {} : () => _signUp()),
                SizedBox(
                  height: media.width * 0.04,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Đã có tài khoản? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Đăng nhập",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }
}
