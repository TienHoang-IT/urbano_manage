import 'package:urbano_manage/Models/nhan_vien_model.dart';

class LoginResultNhanVien {
  final String token;
  final NhanVien nhanVien;

  LoginResultNhanVien({required this.token, required this.nhanVien});

  factory LoginResultNhanVien.fromJson(Map<String, dynamic> json) {
    return LoginResultNhanVien(
      token: json['accessToken'] as String,
      nhanVien: NhanVien.fromJson(json['user']),
    );
  }
}
