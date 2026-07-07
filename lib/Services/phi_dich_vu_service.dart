import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/phi_dich_vu_model.dart';

class PhiDichVuService {
  static const String apiUrl = '${ApiConfig.baseUrl}/PhiDichVu';

  /// Fetches the list of all service fees.
  Future<List<PhiDichVu>> fetchPhiDichVus() async {
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
      return listJson.map((item) => PhiDichVu.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách phí dịch vụ (${response.statusCode})');
    }
  }

  /// Creates a new service fee.
  Future<PhiDichVu> createPhiDichVu(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return PhiDichVu.fromJson(decoded);
    } else {
      throw Exception('Không thể thêm phí dịch vụ mới (${response.statusCode})');
    }
  }

  /// Updates an existing service fee.
  Future<bool> updatePhiDichVu(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes a service fee.
  Future<bool> deletePhiDichVu(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Lookup fee types (LoaiPhiDichVu)
  Future<List<Map<String, dynamic>>> fetchLoaiPhiDichVus() async {
    final response = await AuthHttp.get(Uri.parse('${ApiConfig.baseUrl}/LoaiPhiDichVu'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Lookup unit types (DonViTinhPhiDichVu)
  Future<List<Map<String, dynamic>>> fetchDonViTinhs() async {
    final response = await AuthHttp.get(Uri.parse('${ApiConfig.baseUrl}/DonViTinhPhiDichVu'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  /// Lookup calculation types (LoaiTinhPhiDichVu)
  Future<List<Map<String, dynamic>>> fetchLoaiTinhPhis() async {
    final response = await AuthHttp.get(Uri.parse('${ApiConfig.baseUrl}/LoaiTinhPhiDichVu'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }
}
