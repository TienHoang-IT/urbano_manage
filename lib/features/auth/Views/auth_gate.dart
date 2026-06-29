import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/features/auth/Views/login_view.dart';
import 'package:urbano_manage/features/main_shell/Views/main_shell_view.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bgDark,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.tealPrimary),
            ),
          );
        }
        final token = snapshot.data;
        if (token != null && token.isNotEmpty) {
          return const MainShell();
        } else {
          return const LoginView();
        }
      },
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
