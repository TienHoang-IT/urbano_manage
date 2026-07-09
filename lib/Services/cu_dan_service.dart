import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';

List<CuDan> parseCuDans(String body) {
  final decoded = jsonDecode(body);
  List listJson = [];
  if (decoded is List) {
    listJson = decoded;
  } else if (decoded is Map && decoded['value'] != null) {
    listJson = decoded['value'];
  }
  return listJson.map((item) => CuDan.fromJson(item)).toList();
}

class CuDanService {
  static const String apiUrl = '${ApiConfig.baseUrl}/CuDan';

  /// Fetches the count of residents by getting the list and returning its length.
  Future<int> getResidentCount() async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse('$apiUrl?pageSize=500'), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.length;
    } else {
      throw Exception('Không thể tải danh sách cư dân (${response.statusCode})');
    }
  }

  /// Fetches the list of residents.
  Future<List<CuDan>> fetchCuDans() async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse('$apiUrl?pageSize=500'), headers: headers);

    if (response.statusCode == 200) {
      return compute(parseCuDans, response.body);
    } else {
      throw Exception('Không thể tải danh sách cư dân (${response.statusCode})');
    }
  }

  /// Creates a new resident.
  Future<CuDan> createCuDan(Map<String, dynamic> data) async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return CuDan.fromJson(decoded);
    } else {
      throw Exception('Không thể tạo cư dân (${response.statusCode})');
    }
  }

  /// Updates an existing resident.
  Future<bool> updateCuDan(int id, Map<String, dynamic> data) async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes a resident.
  Future<bool> deleteCuDan(int id) async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: headers,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Fetches a resident details by ID.
  Future<CuDan> fetchCuDanById(int id) async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse('$apiUrl/$id'), headers: headers);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return CuDan.fromJson(decoded);
    } else {
      throw Exception('Không thể tải chi tiết cư dân (${response.statusCode})');
    }
  }

  /// Verifies a resident.
  Future<bool> verifyCuDan(int id) async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.put(
      Uri.parse('$apiUrl/$id/verify'),
      headers: headers,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
