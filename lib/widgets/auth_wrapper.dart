import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../view/bmi_edit/height_input_view.dart';
import '../view/main_tab/main_tab_view.dart';
import '../view/on_boarding/started_view.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        print('AuthWrapper - ConnectionState: ${snapshot.connectionState}');
        print('AuthWrapper - Has data: ${snapshot.hasData}');
        print('AuthWrapper - User: ${snapshot.data?.uid}');
        print('AuthWrapper - User is null: ${snapshot.data == null}');

        // Hiển thị loading khi đang kiểm tra authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang kiểm tra đăng nhập...'),
                ],
              ),
            ),
          );
        }

        // Nếu có user đã đăng nhập, hiển thị main app
        if (snapshot.hasData && snapshot.data != null) {
          print('AuthWrapper - User authenticated, showing MainTabView');
          return const MainTabView();
        }

        // Nếu chưa đăng nhập, hiển thị started view (onboarding)
        print('AuthWrapper - No user, showing StartedView');
        return const StartedView();
      },
    );
  }
}
