import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';
import 'package:urbano_manage/Models/loai_yeu_cau_model.dart';

class YeuCauCuDanService {
  static const String apiUrl = 'http://103.116.39.175/api/YeuCauCuDan';

  /// Fetches resident requests list, optionally filtered by status
  Future<List<YeuCauCuDan>> fetchYeuCaus({int? trangThai}) async {
    String url = apiUrl;
    if (trangThai != null) {
      url = '$apiUrl?trangThai=$trangThai';
    }

    final response = await http.get(Uri.parse(url));

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

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Fetches request types list
  Future<List<LoaiYeuCau>> fetchLoaiYeuCaus() async {
    final url = '$apiUrl/loai-yeu-cau';
    final response = await http.get(Uri.parse(url));

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
}
