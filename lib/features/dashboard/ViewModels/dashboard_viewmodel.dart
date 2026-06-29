import 'package:flutter/material.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';
import 'package:urbano_manage/Services/yeu_cau_cu_dan_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final CuDanService _cuDanService;
  final HoaDonService _hoaDonService;
  final YeuCauCuDanService _yeuCauService;

  DashboardViewModel({
    CuDanService? cuDanService,
    HoaDonService? hoaDonService,
    YeuCauCuDanService? yeuCauService,
  })  : _cuDanService = cuDanService ?? CuDanService(),
        _hoaDonService = hoaDonService ?? HoaDonService(),
        _yeuCauService = yeuCauService ?? YeuCauCuDanService();

  bool isLoading = false;
  String? error;

  int? residentCount;
  int? apartmentCount; // will be null since no API yet
  int? unpaidBillCount;
  int? pendingRequestCount;

  Future<void> fetchDashboardData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _cuDanService.getResidentCount(),
        _hoaDonService.getUnpaidCount(),
        _yeuCauService.fetchYeuCaus(trangThai: 1),
      ]);

      residentCount = results[0] as int;
      unpaidBillCount = results[1] as int;
      
      final pendingRequests = results[2] as List;
      pendingRequestCount = pendingRequests.length;
      
      apartmentCount = null; // No API yet, displays '—'
      error = null;
    } catch (e) {
      debugPrint('Error fetching dashboard statistics: $e');
      error = 'Không thể tải dữ liệu thống kê. Vui lòng thử lại.';
      residentCount = null;
      unpaidBillCount = null;
      pendingRequestCount = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
