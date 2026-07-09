import 'dart:convert';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';
import 'package:urbano_manage/Models/global_search_model.dart';

class TimKiemService {
  static const String apiUrl = '${ApiConfig.baseUrl}/TimKiem';

  Future<GlobalSearchData> search(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final response = await AuthHttp.get(Uri.parse('$apiUrl?q=$encodedKeyword'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return GlobalSearchData.fromJson(decoded);
    } else {
      throw Exception('Không thể tìm kiếm (${response.statusCode})');
    }
  }
}
