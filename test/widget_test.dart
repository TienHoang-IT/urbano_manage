import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/features/auth/Views/login_view.dart';

void main() {
  testWidgets('LoginView renders greeting and input fields correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginView(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Đăng Nhập'), findsOneWidget);
  });
}
