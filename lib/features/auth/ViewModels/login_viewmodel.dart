import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';
import 'package:urbano_manage/Services/auth_services.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthServices _services = AuthServices();
  bool isLoading = false;
  String? error;

  String? token;
  NhanVien? nhanVien;

  Future<bool> login(String account, String password) async {
    if (account.trim().isEmpty || password.isEmpty) {
      error = 'Vui lòng nhập đầy đủ thông tin';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      error = 'Mật khẩu ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _services.login(account.trim(), password);
      token = result.token;
      nhanVien = result.nhanVien;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result.token);
      await prefs.setString('nhanVien', jsonEncode(result.nhanVien.toJson()));
      
      // Role mapping:
      // 1 or 6 = Quản lý / Admin
      // 2 = Kế toán
      // 5 = Bảo vệ
      // others = Nhân viên
      String role = 'Nhân viên';
      if (result.nhanVien.chucVu == 1 || result.nhanVien.chucVu == 6) {
        role = 'Quản lý';
      } else if (result.nhanVien.chucVu == 2) {
        role = 'Kế toán';
      } else if (result.nhanVien.chucVu == 5) {
        role = 'Bảo vệ';
      }
      await prefs.setString('role', role);
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi đăng nhập nhân viên: $e');
      error = 'Sai tài khoản hoặc mật khẩu';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
