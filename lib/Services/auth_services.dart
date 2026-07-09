import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano_manage/Models/login_result_nhan_vien.dart';

import 'package:urbano_manage/core/constants/api_config.dart';

class AuthServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<LoginResultNhanVien> login(String account, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nhanvien/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account': account,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LoginResultNhanVien.fromJson(data);
    } else {
      throw Exception('Đăng nhập thất bại (${response.statusCode})');
    }
  }
}
