import 'dart:convert';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';

class TienIchService {
  static const String apiUrl = '${ApiConfig.baseUrl}/TienIch';

  /// Fetches all utilities
  Future<List<TienIch>> fetchTienIchs() async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl?pageSize=500'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => TienIch.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách tiện ích (${response.statusCode})');
    }
  }

  /// Fetches a single utility by ID
  Future<TienIch> getById(int id) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return TienIch.fromJson(decoded);
    } else {
      throw Exception('Không thể tải thông tin chi tiết tiện ích (${response.statusCode})');
    }
  }

  /// Creates a new utility
  Future<TienIch> createTienIch(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return TienIch.fromJson(decoded);
    } else {
      throw Exception('Không thể thêm tiện ích mới (${response.statusCode})');
    }
  }

  /// Updates an existing utility
  Future<bool> updateTienIch(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes a utility
  Future<bool> deleteTienIch(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Fetches utility types (LoaiTienIch)
  Future<List<Map<String, dynamic>>> fetchLoaiTienIchs() async {
    final response = await AuthHttp.get(Uri.parse('${ApiConfig.baseUrl}/LoaiTienIch'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }
}
