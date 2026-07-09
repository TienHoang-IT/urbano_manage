import 'package:flutter/material.dart';
import 'package:urbano_manage/Services/dashboard_service.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';
import 'package:urbano_manage/Services/yeu_cau_cu_dan_service.dart';
import 'package:urbano_manage/Models/dashboard_models.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService;
  final CuDanService? _cuDanService;
  final HoaDonService? _hoaDonService;
  final YeuCauCuDanService? _yeuCauService;

  DashboardViewModel({
    DashboardService? dashboardService,
    dynamic cuDanService,
    dynamic hoaDonService,
    dynamic yeuCauService,
  })  : _dashboardService = dashboardService ?? DashboardService(),
        _cuDanService = cuDanService as CuDanService?,
        _hoaDonService = hoaDonService as HoaDonService?,
        _yeuCauService = yeuCauService as YeuCauCuDanService?;

  bool isLoading = false;
  String? error;

  DashboardStatistics? statistics;
  Map<String, dynamic> _rawJson = {};

  // Legacy helper getters for compatibility:
  int? get residentCount => statistics?.tongQuan.totalCuDan;
  int? get apartmentCount => statistics?.tongQuan.totalCanHo;
  int? get unpaidBillCount => statistics?.tongQuan.hoaDonChuaThanhToan;
  int? get pendingRequestCount => statistics?.tongQuan.yeuCauChoXuLy;

  double? get revenueTotal {
    if (_rawJson['doanhThuHoaDon'] != null) {
      return (_rawJson['doanhThuHoaDon']['tongTienHoaDon'] as num?)?.toDouble();
    }
    if (statistics?.doanhThu6Thang.isNotEmpty == true) {
      return statistics!.doanhThu6Thang.map((e) => e.tongTien).reduce((a, b) => a + b);
    }
    return null;
  }

  double? get revenuePaid {
    if (_rawJson['doanhThuHoaDon'] != null) {
      return (_rawJson['doanhThuHoaDon']['tongTienDaThu'] as num?)?.toDouble();
    }
    if (statistics?.doanhThu6Thang.isNotEmpty == true) {
      return statistics!.doanhThu6Thang.map((e) => e.daThu).reduce((a, b) => a + b);
    }
    return null;
  }

  double? get revenueUnpaid {
    if (_rawJson['doanhThuHoaDon'] != null) {
      return (_rawJson['doanhThuHoaDon']['soTienChuaThu'] as num?)?.toDouble();
    }
    if (statistics?.doanhThu6Thang.isNotEmpty == true) {
      final total = revenueTotal ?? 0.0;
      final paid = revenuePaid ?? 0.0;
      return total - paid;
    }
    return null;
  }

  int? get reqPendingCount {
    if (_rawJson['yeuCauCuDanTheoTrangThai'] != null) {
      return _rawJson['yeuCauCuDanTheoTrangThai']['Chờ xử lý'] as int?;
    }
    return statistics?.tongQuan.yeuCauChoXuLy;
  }

  Future<void> fetchDashboardData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final detailedStats = await _dashboardService.fetchStatistics();
      _rawJson = detailedStats;

      Map<String, dynamic> stats = {};
      try {
        stats = await _dashboardService.fetchStats();
      } catch (_) {}

      final tqJson = detailedStats['tongQuan'] as Map<String, dynamic>? ?? stats;
      final cbJson = detailedStats['canhBao'] as Map<String, dynamic>? ?? {};
      final dtList = detailedStats['doanhThu6Thang'] as List? ?? [];
      final ycList = detailedStats['yeuCauTheoLoai'] as List? ?? [];

      statistics = DashboardStatistics(
        tongQuan: TongQuan.fromJson(tqJson),
        doanhThu6Thang: dtList.map((e) => DoanhThuThang.fromJson(e as Map<String, dynamic>)).toList(),
        yeuCauTheoLoai: ycList.map((e) => YeuCauTheoLoai.fromJson(e as Map<String, dynamic>)).toList(),
        canhBao: CanhBao.fromJson(cbJson),
      );
      error = null;
    } catch (e) {
      debugPrint('Error fetching dashboard statistics: $e');
      try {
        int? rCount;
        int? uBillCount;
        int? pendingReqCount;
        int? apCount;

        if (_cuDanService != null) {
          rCount = await _cuDanService.getResidentCount();
        }
        if (_hoaDonService != null) {
          uBillCount = await _hoaDonService.getUnpaidCount();
        }
        if (_yeuCauService != null) {
          final reqs = await _yeuCauService.fetchYeuCaus(trangThai: 1);
          pendingReqCount = reqs.length;
        }

        Map<String, dynamic> fallbackStats = {};
        try {
          fallbackStats = await _dashboardService.fetchStats();
        } catch (_) {}

        apCount = fallbackStats['totalCanHo'] as int?;
        if (rCount == null && fallbackStats['totalCuDan'] != null) {
          rCount = fallbackStats['totalCuDan'] as int?;
        }
        if (uBillCount == null && fallbackStats['hoaDonChuaThanhToan'] != null) {
          uBillCount = fallbackStats['hoaDonChuaThanhToan'] as int?;
        }
        if (pendingReqCount == null && fallbackStats['yeuCauChoXuLy'] != null) {
          pendingReqCount = fallbackStats['yeuCauChoXuLy'] as int?;
        }

        statistics = DashboardStatistics(
          tongQuan: TongQuan(
            totalCuDan: rCount ?? 0,
            totalCanHo: apCount ?? 0,
            hoaDonChuaThanhToan: uBillCount ?? 0,
            yeuCauChoXuLy: pendingReqCount ?? 0,
          ),
          doanhThu6Thang: [],
          yeuCauTheoLoai: [],
          canhBao: CanhBao(hoaDonQuaHan: 0, yeuCauQuaHan7Ngay: 0, canHoTrong: 0),
        );
        error = null;
      } catch (fallbackError) {
        error = 'Không thể tải dữ liệu thống kê. Vui lòng thử lại.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
