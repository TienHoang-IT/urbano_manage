import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';
import 'package:urbano_manage/Models/loai_yeu_cau_model.dart';

import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';

class YeuCauCuDanService {
  static const String apiUrl = '${ApiConfig.baseUrl}/YeuCauCuDan';

  /// Fetches resident requests list, optionally filtered by status
  Future<List<YeuCauCuDan>> fetchYeuCaus({int? trangThai}) async {
    String url = apiUrl;
    if (trangThai != null) {
      url = '$apiUrl?trangThai=$trangThai';
    }

    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse('$url${url.contains('?') ? '&' : '?'}pageSize=500'), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => YeuCauCuDan.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách yêu cầu (${response.statusCode})');
    }
  }

  /// Updates status of a request (Approve/Reject/In Progress)
  Future<bool> updateStatus(int id, int trangThai, int? nhanVienXuLy) async {
    final url = '$apiUrl/$id/status';
    final body = jsonEncode({
      'trangThai': trangThai,
      'nhanVienXuLy': nhanVienXuLy,
    });

    final headers = await AuthHttp.getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Fetches request types list
  Future<List<LoaiYeuCau>> fetchLoaiYeuCaus() async {
    final url = '$apiUrl/loai-yeu-cau';
    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse('$url?pageSize=500'), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => LoaiYeuCau.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải loại yêu cầu (${response.statusCode})');
    }
  }

  /// Creates a resident request.
  Future<YeuCauCuDan> createYeuCau(Map<String, dynamic> data) async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return YeuCauCuDan.fromJson(decoded);
    } else {
      throw Exception('Không thể tạo yêu cầu mới (${response.statusCode})');
    }
  }

  /// Deletes a resident request.
  Future<bool> deleteYeuCau(int id) async {
    final url = '$apiUrl/$id';
    final headers = await AuthHttp.getHeaders();
    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
