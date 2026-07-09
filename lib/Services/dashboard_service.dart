import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';

class DashboardService {
  static const String apiUrl = '${ApiConfig.baseUrl}/Dashboard';

  /// Fetches statistics for the dashboard.
  Future<Map<String, dynamic>> fetchStatistics() async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/statistics'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Không thể tải dữ liệu thống kê (${response.statusCode})');
  }

  /// Fetches brief dashboard count statistics.
  Future<Map<String, dynamic>> fetchStats() async {
    final response = await AuthHttp.get(Uri.parse('$apiUrl/stats'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Không thể tải dữ liệu thống kê thu gọn (${response.statusCode})');
  }
}
