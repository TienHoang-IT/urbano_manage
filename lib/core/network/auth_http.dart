import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/main.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';

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

  /// Handles unauthorized (401) responses by clearing user session and redirecting to login.
  static void _handleUnauthorized() async {
    // Đã vô hiệu hóa để tránh bị out ra khỏi dashboard khi hết phiên đăng nhập (401 Unauthorized)
    /*
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nhanVien');
    
    // Redirect to LoginView using global key
    MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );

    // Display expiration alert
    MyApp.messengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    */
  }

  static void _showNoPermissionSnackBar() {
    MyApp.messengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Bạn không có quyền'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Wrapper for HTTP GET requests that intercepts 401/403 errors.
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final mergedHeaders = await getHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    final response = await http.get(url, headers: mergedHeaders);
    if (response.statusCode == 401 || response.statusCode == 403) {
      _showNoPermissionSnackBar();
      throw Exception('Bạn không có quyền (${response.statusCode})');
    }
    return response;
  }

  /// Wrapper for HTTP POST requests that intercepts 401/403 errors.
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = await getHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    final response = await http.post(url, headers: mergedHeaders, body: body);
    if (response.statusCode == 401 || response.statusCode == 403) {
      _showNoPermissionSnackBar();
      throw Exception('Bạn không có quyền (${response.statusCode})');
    }
    return response;
  }

  /// Wrapper for HTTP PUT requests that intercepts 401/403 errors.
  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = await getHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    final response = await http.put(url, headers: mergedHeaders, body: body);
    if (response.statusCode == 401 || response.statusCode == 403) {
      _showNoPermissionSnackBar();
      throw Exception('Bạn không có quyền (${response.statusCode})');
    }
    return response;
  }

  /// Wrapper for HTTP DELETE requests that intercepts 401/403 errors.
  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = await getHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    final response = await http.delete(url, headers: mergedHeaders, body: body);
    if (response.statusCode == 401 || response.statusCode == 403) {
      _showNoPermissionSnackBar();
      throw Exception('Bạn không có quyền (${response.statusCode})');
    }
    return response;
  }
}
