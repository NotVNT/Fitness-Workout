import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:fitness/providers/user_provider.dart';

import '../bmi_edit/height_input_view.dart';
import 'package:fitness/view/login/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _signIn() async {
    // Validation
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập email');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập mật khẩu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result != null) {
        // Đăng nhập thành công: nếu user đã có đủ BMI (height, weight, targetWeight) thì vào thẳng Main.
        // Nếu thiếu, dẫn qua flow nhập BMI.
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        // Lấy context hiện tại vào biến cục bộ để tránh lỗi across async gaps
        final navigator = Navigator.of(context);
        await userProvider.loadUserData();
        if (!mounted) return;

        final u = userProvider.user;
        final hasBMI = (u?.height ?? 0) > 0 &&
            (u?.weight ?? 0) > 0 &&
            (u?.targetWeight ?? 0) > 0;

        if (hasBMI) {
          navigator.pushReplacementNamed('/main');
        } else {
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HeightInputView(
                navigateToMainOnComplete: true,
              ),
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
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quên mật khẩu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nhập email của bạn để nhận link đặt lại mật khẩu',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                // Hỗ trợ tiếng Việt có dấu
                enableIMEPersonalizedLearning: true,
                autocorrect: false, // Tắt để không can thiệp vào dấu
                enableSuggestions: false, // Tắt để không làm mất dấu
                textAlign: TextAlign.start,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  _showErrorMessage('Vui lòng nhập email');
                  return;
                }

                try {
                  await _authService.resetPassword(email);
                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSuccessMessage(
                        'Email đặt lại mật khẩu đã được gửi đến $email');
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorMessage(_authService.getErrorMessage(e));
                  }
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  bool isCheck = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Xin chào,",
                  style: TextStyle(color: TColor.gray, fontSize: 16),
                ),
                Text(
                  "Chào mừng trở lại",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  hitText: "Email",
                  icon: "assets/img/email.png",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _showForgotPasswordDialog,
                      child: Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 10,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                RoundButton(
                    title: _isLoading ? "Đang đăng nhập..." : "Đăng nhập",
                    onPressed: _isLoading ? () {} : () => _signIn()),
                SizedBox(
                  height: media.width * 0.04,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpView(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Chưa có tài khoản ? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Đăng ký",
                        style: TextStyle(
                            color: TColor.primaryColor1,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
