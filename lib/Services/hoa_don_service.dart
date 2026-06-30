import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';

class HoaDonService {
  static const String apiUrl = '${ApiConfig.baseUrl}/HoaDon';

  /// Fetches the count of unpaid bills (trangThai = 1).
  Future<int> getUnpaidCount() async {
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
      final unpaidList = listJson.where((item) => item['trangThai'] == 1).toList();
      return unpaidList.length;
    } else {
      throw Exception('Không thể tải danh sách hóa đơn (${response.statusCode})');
    }
  }

  /// Fetches the list of all invoices.
  Future<List<HoaDon>> fetchHoaDons() async {
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
      return listJson.map((item) => HoaDon.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách hóa đơn (${response.statusCode})');
    }
  }

  /// Creates a new invoice.
  Future<HoaDon> createHoaDon(Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return HoaDon.fromJson(decoded);
    } else {
      throw Exception('Không thể tạo hóa đơn mới (${response.statusCode})');
    }
  }

  /// Updates an invoice.
  Future<bool> updateHoaDon(int id, Map<String, dynamic> data) async {
    final response = await AuthHttp.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Deletes an invoice.
  Future<bool> deleteHoaDon(int id) async {
    final response = await AuthHttp.delete(Uri.parse('$apiUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Adds a detail fee line item to the invoice.
  Future<Map<String, dynamic>> addChiTiet(int hoaDonId, Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse('$apiUrl/$hoaDonId/chitiet'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('Không thể thêm chi tiết hóa đơn (${response.statusCode})');
    }
  }

  /// Records a payment for the invoice.
  Future<bool> payHoaDon(int hoaDonId, Map<String, dynamic> data) async {
    final response = await AuthHttp.post(
      Uri.parse('$apiUrl/$hoaDonId/pay'),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Fetches detail fee line items for a specific invoice.
  Future<List<Map<String, dynamic>>> fetchChiTietHoaDons(int hoaDonId) async {
    try {
      final response = await AuthHttp.get(Uri.parse('$apiUrl/$hoaDonId/chitiet'));
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
        return listJson.map((item) => item as Map<String, dynamic>).toList();
      }
      // If endpoint returns 404 or others, return empty to support local DB testing
      return [];
    } catch (_) {
      return [];
    }
  }
}
