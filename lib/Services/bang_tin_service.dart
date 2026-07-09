import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/bang_tin_model.dart';

class BangTinService {
  static const String apiUrl = '${ApiConfig.baseUrl}/BangTin';

  /// Fetches all board messages.
  Future<List<BangTin>> fetchAll() async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl?pageSize=500'));

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
      return listJson.map((e) => BangTin.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải bảng tin (${response.statusCode})');
    }
  }

  /// Creates a message board item.
  Future<BangTin> create(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return BangTin.fromJson(decoded);
    } else {
      throw Exception('Không thể thêm bảng tin mới (${response.statusCode})');
    }
  }

  /// Updates a message board item.
  Future<bool> update(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes a message board item.
  Future<bool> delete(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
