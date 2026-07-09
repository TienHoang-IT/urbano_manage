import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/lich_su_thanh_toan_model.dart';

class LichSuThanhToanService {
  static const String apiUrl = '${ApiConfig.baseUrl}/LichSuThanhToan';

  /// Fetches all payment histories.
  Future<List<LichSuThanhToan>> fetchAll() async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl?pageSize=500'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((e) => LichSuThanhToan.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải lịch sử thanh toán (${response.statusCode})');
    }
  }

  /// Fetches payment histories for a specific invoice.
  Future<List<LichSuThanhToan>> fetchByHoaDon(int hoaDonId) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/hoadon/$hoaDonId'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((e) => LichSuThanhToan.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải lịch sử thanh toán của hóa đơn (${response.statusCode})');
    }
  }
}
