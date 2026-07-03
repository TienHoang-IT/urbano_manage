import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/cu_dan_can_ho_model.dart';

class CuDanCanHoService {
  static const String apiUrl = '${ApiConfig.baseUrl}/CuDanCanHo';

  Future<List<CuDanCanHo>> fetchByCanHo(int canHoId) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/canho/$canHoId'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return (list as List).map((e) => CuDanCanHo.fromJson(e)).toList();
    }
    throw Exception('Không thể tải lịch sử cư dân của căn hộ (${response.statusCode})');
  }

  Future<List<CuDanCanHo>> fetchByCuDan(int cuDanId) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/cudan/$cuDanId'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return (list as List).map((e) => CuDanCanHo.fromJson(e)).toList();
    }
    throw Exception('Không thể tải lịch sử căn hộ của cư dân (${response.statusCode})');
  }

  Future<bool> assignCuDanCanHo(Map<String, dynamic> body) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(body),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> chuyenDi(int id) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id/chuyen-di'),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> delete(int id) async {
    final response = await AuthHttp.delete(
      Uri.parse('$apiUrl/$id'),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
