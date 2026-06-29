import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/network/auth_http.dart';

class CuDanService {
  static const String apiUrl = '${ApiConfig.baseUrl}/CuDan';

  /// Fetches the count of residents by getting the list and returning its length.
  Future<int> getResidentCount() async {
    final headers = await AuthHttp.getHeaders();
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

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
}
