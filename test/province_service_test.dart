import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:urbano_manage/Services/province_service.dart';

void main() {
  group('ProvinceService Tests', () {
    test('fetchProvinces returns list of provinces and caches result', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        if (request.url.toString() == 'https://provinces.open-api.vn/api/v2/p/') {
          return http.Response(
            jsonEncode([
              {'code': 1, 'name': 'Thành phố Hà Nội', 'codename': 'ha_noi', 'division_type': 'thành phố'},
              {'code': 79, 'name': 'Thành phố Hồ Chí Minh', 'codename': 'ho_chi_minh', 'division_type': 'thành phố'},
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = ProvinceService(client: mockClient);
      final provinces = await service.fetchProvinces();

      expect(provinces.length, 2);
      expect(provinces.first.name, 'Thành phố Hà Nội');
      expect(provinces.first.code, 1);
      expect(callCount, 1);

      // Second call should return cached data without extra HTTP request
      final cachedProvinces = await service.fetchProvinces();
      expect(cachedProvinces.length, 2);
      expect(callCount, 1);
    });

    test('fetchWards returns list of wards for province and caches result', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        if (request.url.toString() == 'https://provinces.open-api.vn/api/v2/p/1?depth=2') {
          return http.Response(
            jsonEncode({
              'code': 1,
              'name': 'Thành phố Hà Nội',
              'wards': [
                {'code': 4, 'name': 'Phường Ba Đình', 'codename': 'phuong_ba_dinh', 'division_type': 'phường', 'province_code': 1},
                {'code': 8, 'name': 'Phường Ngọc Hà', 'codename': 'phuong_ngoc_ha', 'division_type': 'phường', 'province_code': 1},
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = ProvinceService(client: mockClient);
      final wards = await service.fetchWards(1);

      expect(wards.length, 2);
      expect(wards.first.name, 'Phường Ba Đình');
      expect(wards.first.code, 4);
      expect(callCount, 1);

      // Second call for same province code should return cached data
      final cachedWards = await service.fetchWards(1);
      expect(cachedWards.length, 2);
      expect(callCount, 1);
    });

    test('fetchProvinces handles HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = ProvinceService(client: mockClient);
      expect(() async => await service.fetchProvinces(), throwsException);
    });
  });
}
