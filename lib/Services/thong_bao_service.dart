import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/thong_bao_model.dart';

class ThongBaoService {
  static const String apiUrl = '${ApiConfig.baseUrl}/ThongBao';

  /// Fetches the list of all notifications.
  Future<List<ThongBao>> fetchThongBaos() async {
    final response = await AuthHttp.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map) {
        if (decoded['value'] != null) {
          listJson = decoded['value'];
        } else if (decoded['data'] != null) {
          listJson = decoded['data'];
        }
      }
      return listJson.map((item) => ThongBao.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách thông báo (${response.statusCode})');
    }
  }

  /// Creates a new notification.
  Future<ThongBao> createThongBao(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return ThongBao.fromJson(decoded);
    } else {
      throw Exception('Không thể tạo thông báo mới (${response.statusCode})');
    }
  }

  /// Updates an existing notification.
  Future<bool> updateThongBao(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes a notification.
  Future<bool> deleteThongBao(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
