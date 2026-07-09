import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/main.dart';

void main() {
  testWidgets('App landing and LoginView rendering smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Allow the asynchronous SharedPreferences.getInstance() to resolve
    await tester.idle();
    await tester.pump();

    // Verify that we land on LoginView and it renders greeting
    expect(find.textContaining('Chào mừng trở lại'), findsOneWidget);
    
    // Verify that Login Button exists
    expect(find.text('Đăng Nhập'), findsOneWidget);
  });
}
