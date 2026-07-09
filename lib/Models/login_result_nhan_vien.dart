import 'package:urbano_manage/Models/nhan_vien_model.dart';

class LoginResultNhanVien {
  final String token;
  final NhanVien nhanVien;

  LoginResultNhanVien({required this.token, required this.nhanVien});

  factory LoginResultNhanVien.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json['nhanVien'] ?? {};
    return LoginResultNhanVien(
      token: (json['accessToken'] ?? json['token']) as String? ?? '',
      nhanVien: NhanVien.fromJson(userJson as Map<String, dynamic>),
    );
  }
}
