import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../view/main_tab/main_tab_view.dart';
import '../view/on_boarding/started_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Hiển thị loading khi đang kiểm tra authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Nếu có user đã đăng nhập, hiển thị main app
        if (snapshot.hasData && snapshot.data != null) {
          return const MainTabView();
        }
        
        // Nếu chưa đăng nhập, hiển thị started view (onboarding)
        return const StartedView();
      },
    );
  }
}
