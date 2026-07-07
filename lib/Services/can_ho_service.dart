import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';

class CanHoService {
  static const String apiUrl = '${ApiConfig.baseUrl}/CanHo';

  /// Fetches the list of all apartments.
  Future<List<CanHo>> fetchCanHos() async {
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
      return listJson.map((item) => CanHo.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách căn hộ (${response.statusCode})');
    }
  }

  /// Creates a new apartment.
  Future<CanHo> createCanHo(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return CanHo.fromJson(decoded);
    } else {
      throw Exception('Không thể thêm căn hộ mới (${response.statusCode})');
    }
  }

  /// Updates an existing apartment.
  Future<bool> updateCanHo(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes an apartment.
  Future<bool> deleteCanHo(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Lookup buildings (ToaNha)
  Future<List<Map<String, dynamic>>> fetchToaNhas() async {
    final response = await AuthHttp.get(Uri.parse('${ApiConfig.baseUrl}/ToaNha'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Lookup apartment types (LoaiCanHo)
  Future<List<Map<String, dynamic>>> fetchLoaiCanHos() async {
    final response = await AuthHttp.get(Uri.parse('${ApiConfig.baseUrl}/LoaiCanHo'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Lookup apartment statuses (TrangThaiCanHo)
  Future<List<Map<String, dynamic>>> fetchTrangThaiCanHos() async {
    final response = await AuthHttp.get(Uri.parse('${ApiConfig.baseUrl}/TrangThaiCanHo'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Fetches an apartment details by ID.
  Future<CanHo> fetchCanHoById(int id) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return CanHo.fromJson(decoded);
    } else {
      throw Exception('Không thể tải chi tiết căn hộ (${response.statusCode})');
    }
  }
}
