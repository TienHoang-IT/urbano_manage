import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/main.dart';
import 'package:urbano_manage/features/auth/Views/login_view.dart';

void main() {
  testWidgets('App landing and LoginView rendering smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we land on LoginView and it renders greeting
    expect(find.textContaining('Chào mừng trở lại'), findsOneWidget);
    
    // Verify that Login Button exists
    expect(find.text('Đăng Nhập'), findsOneWidget);
  });
}
