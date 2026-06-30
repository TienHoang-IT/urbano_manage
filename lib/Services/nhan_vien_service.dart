import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';

class NhanVienService {
  static const String apiUrl = '${ApiConfig.baseUrl}/NhanVien';

  /// Fetches the list of all employees.
  Future<List<NhanVien>> fetchNhanViens() async {
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
      return listJson.map((item) => NhanVien.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách nhân viên (${response.statusCode})');
    }
  }

  /// Creates a new employee.
  Future<NhanVien> createNhanVien(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return NhanVien.fromJson(decoded);
    } else {
      throw Exception('Không thể thêm nhân viên mới (${response.statusCode})');
    }
  }

  /// Updates an existing employee.
  Future<bool> updateNhanVien(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes an employee.
  Future<bool> deleteNhanVien(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
