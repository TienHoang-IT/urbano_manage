import 'dart:convert';
import 'package:http/http.dart' as http;

class Province {
  final int code;
  final String name;
  final String codename;
  final String divisionType;

  Province({
    required this.code,
    required this.name,
    required this.codename,
    required this.divisionType,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      codename: json['codename'] as String? ?? '',
      divisionType: json['division_type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'codename': codename,
        'division_type': divisionType,
      };
}

class Ward {
  final int code;
  final String name;
  final String codename;
  final String divisionType;
  final int provinceCode;

  Ward({
    required this.code,
    required this.name,
    required this.codename,
    required this.divisionType,
    required this.provinceCode,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['code'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      codename: json['codename'] as String? ?? '',
      divisionType: json['division_type'] as String? ?? '',
      provinceCode: json['province_code'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'codename': codename,
        'division_type': divisionType,
        'province_code': provinceCode,
      };
}

class ProvinceService {
  static const String baseUrl = 'https://provinces.open-api.vn/api/v2';
  final http.Client _client;

  List<Province>? _cachedProvinces;
  final Map<int, List<Ward>> _cachedWardsByProvince = {};

  ProvinceService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the list of all provinces in API v2
  Future<List<Province>> fetchProvinces() async {
    if (_cachedProvinces != null && _cachedProvinces!.isNotEmpty) {
      return _cachedProvinces!;
    }

    final response = await _client.get(Uri.parse('$baseUrl/p/'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      _cachedProvinces = listJson.map((item) => Province.fromJson(item)).toList();
      return _cachedProvinces!;
    } else {
      throw Exception('Không thể tải danh sách tỉnh thành (${response.statusCode})');
    }
  }

  /// Fetches the list of wards for a given province code in API v2
  Future<List<Ward>> fetchWards(int provinceCode) async {
    if (_cachedWardsByProvince.containsKey(provinceCode)) {
      return _cachedWardsByProvince[provinceCode]!;
    }

    final response = await _client.get(Uri.parse('$baseUrl/p/$provinceCode?depth=2'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List wardsJson = [];
      if (decoded is Map && decoded['wards'] != null) {
        wardsJson = decoded['wards'];
      }
      final wards = wardsJson.map((item) => Ward.fromJson(item)).toList();
      _cachedWardsByProvince[provinceCode] = wards;
      return wards;
    } else {
      throw Exception('Không thể tải danh sách phường xã (${response.statusCode})');
    }
  }
}
