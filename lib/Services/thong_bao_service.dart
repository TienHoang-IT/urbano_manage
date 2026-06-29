import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/thong_bao_model.dart';

class ThongBaoService {
  static const String apiUrl = '${ApiConfig.baseUrl}/ThongBao';

  /// Fetches the list of all notifications.
  Future<List<ThongBao>> fetchThongBaos() async {
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
      return listJson.map((item) => ThongBao.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách thông báo (${response.statusCode})');
    }
  }
}
