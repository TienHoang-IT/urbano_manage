import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';

class HoaDonService {
  static const String apiUrl = '${ApiConfig.baseUrl}/HoaDon';

  /// Fetches the count of unpaid bills (trangThai = 1).
  Future<int> getUnpaidCount() async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      final unpaidList = listJson.where((item) => item['trangThai'] == 1).toList();
      return unpaidList.length;
    } else {
      throw Exception('Không thể tải danh sách hóa đơn (${response.statusCode})');
    }
  }

  /// Fetches the list of all invoices.
  Future<List<HoaDon>> fetchHoaDons() async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => HoaDon.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách hóa đơn (${response.statusCode})');
    }
  }
}
