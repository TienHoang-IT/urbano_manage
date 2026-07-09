import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/dashboard/ViewModels/dashboard_viewmodel.dart';
import 'package:urbano_manage/Services/dashboard_service.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';
import 'package:urbano_manage/Services/yeu_cau_cu_dan_service.dart';
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';

class FakeDashboardService extends DashboardService {
  final bool shouldFail;
  final Map<String, dynamic>? response;
  final Map<String, dynamic>? statsResponse;
  FakeDashboardService({this.shouldFail = true, this.response, this.statsResponse});

  @override
  Future<Map<String, dynamic>> fetchStatistics() async {
    if (shouldFail) throw Exception('API not implemented');
    return response ?? {};
  }

  @override
  Future<Map<String, dynamic>> fetchStats() async {
    // fetchStats is the lightweight fallback endpoint — always returns data
    return statsResponse ?? {
      'totalCuDan': 10,
      'totalCanHo': 45,
      'hoaDonChuaThanhToan': 5,
      'yeuCauChoXuLy': 1,
    };
  }
}

class FakeCuDanService extends CuDanService {
  final int count;
  final bool shouldFail;
  FakeCuDanService({required this.count, this.shouldFail = false});

  @override
  Future<int> getResidentCount() async {
    if (shouldFail) throw Exception('Failed to get resident count');
    return count;
  }
}

class FakeHoaDonService extends HoaDonService {
  final int count;
  final bool shouldFail;
  FakeHoaDonService({required this.count, this.shouldFail = false});

  @override
  Future<int> getUnpaidCount() async {
    if (shouldFail) throw Exception('Failed to get unpaid count');
    return count;
  }
}

class FakeYeuCauCuDanService extends YeuCauCuDanService {
  final List<YeuCauCuDan> list;
  final bool shouldFail;
  FakeYeuCauCuDanService({required this.list, this.shouldFail = false});

  @override
  Future<List<YeuCauCuDan>> fetchYeuCaus({int? trangThai}) async {
    if (shouldFail) throw Exception('Failed to get requests');
    return list;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardViewModel Tests', () {
    test('fetchDashboardData successfully updates counts via fallback', () async {
      final dashboardService = FakeDashboardService(shouldFail: true);
      final cuDanService = FakeCuDanService(count: 10);
      final hoaDonService = FakeHoaDonService(count: 5);
      final yeuCauService = FakeYeuCauCuDanService(list: [
        YeuCauCuDan(
          id: 1,
          cuDan: 1,
          tenCuDan: 'Resident',
          loaiYeuCau: 1,
          tenLoaiYeuCau: 'Type',
          tieuDe: 'Title',
          noiDung: 'Content',
          ngayGui: DateTime.now(),
          mucDoUuTien: 1,
          mucDoUuTienText: 'Thường',
          trangThai: 1,
          trangThaiText: 'Chờ xử lý',
          tenNhanVienXuLy: '',
          tenNguoiCapNhat: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      ]);

      final viewModel = DashboardViewModel(
        dashboardService: dashboardService,
        cuDanService: cuDanService,
        hoaDonService: hoaDonService,
        yeuCauService: yeuCauService,
      );

      expect(viewModel.residentCount, isNull);
      expect(viewModel.unpaidBillCount, isNull);
      expect(viewModel.pendingRequestCount, isNull);

      await viewModel.fetchDashboardData();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.residentCount, 10);
      expect(viewModel.apartmentCount, 45); // Fallback mock value
      expect(viewModel.unpaidBillCount, 5);
      expect(viewModel.pendingRequestCount, 1);
    });

    test('fetchDashboardData successfully fetches from API stats', () async {
      final dashboardService = FakeDashboardService(
        shouldFail: false,
        statsResponse: {
          'totalCuDan': 12,
          'totalCanHo': 50,
          'hoaDonChuaThanhToan': 2,
          'yeuCauChoXuLy': 3,
        },
        response: {
          'doanhThuHoaDon': {
            'tongTienHoaDon': 1000.0,
            'tongTienDaThu': 800.0,
            'soTienChuaThu': 200.0,
          },
          'yeuCauCuDanTheoTrangThai': {
            'Chờ xử lý': 3,
            'Đang xử lý': 1,
            'Hoàn thành': 10,
            'Từ chối': 0,
          }
        }
      );
      
      final viewModel = DashboardViewModel(
        dashboardService: dashboardService,
      );

      await viewModel.fetchDashboardData();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.residentCount, 12);
      expect(viewModel.apartmentCount, 50);
      expect(viewModel.unpaidBillCount, 2);
      expect(viewModel.pendingRequestCount, 3);
      expect(viewModel.revenueTotal, 1000.0);
      expect(viewModel.revenuePaid, 800.0);
      expect(viewModel.revenueUnpaid, 200.0);
      expect(viewModel.reqPendingCount, 3);
    });

    test('fetchDashboardData handles error gracefully', () async {
      final dashboardService = FakeDashboardService(shouldFail: true);
      final cuDanService = FakeCuDanService(count: 10, shouldFail: true);
      final hoaDonService = FakeHoaDonService(count: 5);
      final yeuCauService = FakeYeuCauCuDanService(list: []);

      final viewModel = DashboardViewModel(
        dashboardService: dashboardService,
        cuDanService: cuDanService,
        hoaDonService: hoaDonService,
        yeuCauService: yeuCauService,
      );

      await viewModel.fetchDashboardData();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
      expect(viewModel.residentCount, isNull);
      expect(viewModel.unpaidBillCount, isNull);
      expect(viewModel.pendingRequestCount, isNull);
    });
  });
}
