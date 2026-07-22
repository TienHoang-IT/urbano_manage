import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/cau_hinh_thanh_toan_model.dart';

class CauHinhThanhToanService {
  static const String apiUrl = '${ApiConfig.baseUrl}/CauHinhThanhToan';

  Future<List<CauHinhThanhToan>> fetchConfigs() async {
    try {
      final response = await AuthHttp.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        List listJson = [];
        if (decoded is List) {
          listJson = decoded;
        } else if (decoded is Map && decoded['value'] != null) {
          listJson = decoded['value'];
        }
        if (listJson.isNotEmpty) {
          return listJson.map((e) => CauHinhThanhToan.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    return [
      CauHinhThanhToan(
        id: 1,
        loaiPhuongThuc: 'ChuyenKhoan',
        tenNhaCungCap: 'MBBank',
        dinhDanhThuHuong: '0987654321',
        maNhanDien: 'MB',
        tenChuTaiKhoan: 'BQL CHUNG CU URBANO',
      ),
    ];
  }
}
