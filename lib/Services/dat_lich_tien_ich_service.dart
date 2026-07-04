import 'dart:convert';
import 'package:urbano_manage/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';

class DatLichTienIchService {
  static const String apiUrl = '${ApiConfig.baseUrl}/DatLichTienIch';

  /// Fetches all bookings
  Future<List<DatLichTienIch>> fetchAll() async {
    final response = await AuthHttp.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => DatLichTienIch.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách đặt lịch tiện ích (${response.statusCode})');
    }
  }

  /// Fetches a single booking by ID
  Future<DatLichTienIch> getById(int id) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return DatLichTienIch.fromJson(decoded);
    } else {
      throw Exception('Không thể tải thông tin chi tiết đặt lịch (${response.statusCode})');
    }
  }

  /// Fetches bookings by utility ID
  Future<List<DatLichTienIch>> getByTienIch(int tienIchId) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/tienich/$tienIchId'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => DatLichTienIch.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách đặt lịch theo tiện ích (${response.statusCode})');
    }
  }

  /// Fetches bookings by resident ID
  Future<List<DatLichTienIch>> getByCuDan(int cuDanId) async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/cudan/$cuDanId'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => DatLichTienIch.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách đặt lịch theo cư dân (${response.statusCode})');
    }
  }

  /// Creates a booking
  Future<DatLichTienIch> create(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return DatLichTienIch.fromJson(decoded);
    } else {
      throw Exception('Không thể tạo lịch đặt mới (${response.statusCode})');
    }
  }

  /// Approves or rejects a booking
  Future<bool> duyet(int id, int trangThai, String? lyDoHuy) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id/duyet'),
      body: jsonEncode({
        'trangThai': trangThai,
        'lyDoHuy': lyDoHuy,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Cancels a booking
  Future<bool> huy(int id) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id/huy'),
      body: '',
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes a booking
  Future<bool> delete(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
