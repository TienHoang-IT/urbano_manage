import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/nhat_ky_he_thong_model.dart';

class NhatKyHeThongService {
  static const String apiUrl = '${ApiConfig.baseUrl}/NhatKyHeThong';

  Future<PagedLogs> fetchLogs({
    String? bangTacDong,
    int? nguoiThucHien,
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
  }) async {
    final queryParams = <String, String>{
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
    };

    if (bangTacDong != null && bangTacDong.isNotEmpty) {
      queryParams['bangTacDong'] = bangTacDong;
    }
    if (nguoiThucHien != null) {
      queryParams['nguoiThucHien'] = nguoiThucHien.toString();
    }
    if (from != null) {
      queryParams['from'] = from.toIso8601String();
    }
    if (to != null) {
      queryParams['to'] = to.toIso8601String();
    }
    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['SearchTerm'] = searchTerm;
    }

    final uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);
    final response = await AuthHttp.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return PagedLogs.fromJson(decoded);
    } else {
      throw Exception('Không thể tải nhật ký hệ thống (${response.statusCode})');
    }
  }
}
