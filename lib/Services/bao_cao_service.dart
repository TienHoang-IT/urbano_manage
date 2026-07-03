import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';

class BaoCaoService {
  static const String apiUrl = '${ApiConfig.baseUrl}/BaoCao';

  Future<Uint8List> getHoaDonExcel(int thang, int nam) async {
    final uri = Uri.parse('$apiUrl/hoa-don/excel?thang=$thang&nam=$nam');
    final response = await AuthHttp.get(uri);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Lỗi xuất báo cáo Excel hóa đơn (${response.statusCode})');
  }

  Future<Uint8List> getBienLaiPdf(int hoaDonId) async {
    final uri = Uri.parse('$apiUrl/hoa-don/pdf?hoaDonId=$hoaDonId');
    final response = await AuthHttp.get(uri);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Lỗi xuất biên lai PDF (${response.statusCode})');
  }

  Future<Uint8List> getThuPhiExcel(int thang, int nam) async {
    final uri = Uri.parse('$apiUrl/thu-phi/excel?thang=$thang&nam=$nam');
    final response = await AuthHttp.get(uri);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Lỗi xuất báo cáo Excel thu phí (${response.statusCode})');
  }
}
