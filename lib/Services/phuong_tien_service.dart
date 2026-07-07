import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/phuong_tien_model.dart';
import 'package:urbano_manage/Models/loai_phuong_tien_model.dart';

class PhuongTienService {
  static const String apiUrl = '${ApiConfig.baseUrl}/PhuongTien';
  static const String loaiUrl = '${ApiConfig.baseUrl}/LoaiPhuongTien';

  /// Fetches the list of all vehicles.
  Future<List<PhuongTien>> fetchAll() async {
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
      return listJson.map((item) => PhuongTien.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách phương tiện (${response.statusCode})');
    }
  }

  /// Creates a new vehicle.
  Future<PhuongTien> create(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return PhuongTien.fromJson(decoded);
    } else {
      throw Exception('Không thể thêm phương tiện mới (${response.statusCode})');
    }
  }

  /// Updates an existing vehicle.
  Future<bool> update(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes a vehicle.
  Future<bool> delete(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Fetches vehicle types list.
  Future<List<LoaiPhuongTien>> fetchLoaiPhuongTiens() async {
    final response = await AuthHttp.get(Uri.parse(loaiUrl));

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
      return listJson.map((item) => LoaiPhuongTien.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải loại phương tiện (${response.statusCode})');
    }
  }

  /// Fetches a vehicle details by ID.
  Future<PhuongTien> fetchById(int id) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return PhuongTien.fromJson(decoded);
    } else {
      throw Exception('Không thể tải chi tiết phương tiện (${response.statusCode})');
    }
  }
}
