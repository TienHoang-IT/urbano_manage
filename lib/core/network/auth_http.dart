import 'package:shared_preferences/shared_preferences.dart';

class AuthHttp {
  /// Reads the token from SharedPreferences and returns the standard HTTP headers.
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      return {
        'Content-Type': 'application/json',
      };
    }
  }
}
