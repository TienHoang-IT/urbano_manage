import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';

class FakeHoaDonService extends HoaDonService {
  final List<HoaDon> list;
  final bool shouldFail;

  FakeHoaDonService({required this.list, this.shouldFail = false});

  @override
  Future<List<HoaDon>> fetchHoaDons() async {
    if (shouldFail) throw Exception('Failed to fetch');
    return list;
  }
  @override
  Future<Map<String, dynamic>> autoBilling(int thang, int nam, int nguoiTao, {int? toaNhaId, DateTime? hanThanhToan, List<String>? feeTypes}) async {
    if (shouldFail) throw Exception('Auto billing failed');
    return {
      'createdCount': 10,
      'skippedCount': 2,
      'totalAmount': 25000000.0,
    };
  }

  @override
  Future<bool> saveBulkMeterReadings(int thang, int nam, List<Map<String, dynamic>> readings) async {
    if (shouldFail) throw Exception('Bulk meter save failed');
    return true;
  }
}

void main() {
  group('HoaDonViewModel Tests', () {
    final testInvoice = HoaDon(
      id: 1,
      maThanhToan: 'HD1',
      canHo: 1,
      soCanHo: '101',
      thang: 6,
      nam: 2026,
      tongTien: 100000.0,
      soTienDaThanhToan: 0.0,
      chiPhi: 100000.0,
      hanThanhToan: DateTime.now().add(const Duration(days: 1)),
      trangThai: 1,
      tenNguoiCapNhat: 'Manager',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('fetchHoaDons successfully filters and loads invoices', () async {
      final service = FakeHoaDonService(list: [testInvoice]);
      final viewModel = HoaDonViewModel(service: service);

      expect(viewModel.hoaDons, isEmpty);

      // Tab 0: All
      await viewModel.fetchHoaDons();
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.hoaDons.length, 1);
      expect(viewModel.hoaDons.first.maThanhToan, 'HD1');

      // Tab 2: Paid (should be empty for our unpaid invoice)
      viewModel.currentTab = 2;
      await viewModel.fetchHoaDons();
      expect(viewModel.hoaDons, isEmpty);

      // Tab 4: Overdue (should be empty because test invoice is not overdue)
      viewModel.currentTab = 4;
      await viewModel.fetchHoaDons();
      expect(viewModel.hoaDons, isEmpty);
    });

    test('fetchHoaDons handles error', () async {
      final service = FakeHoaDonService(list: [], shouldFail: true);
      final viewModel = HoaDonViewModel(service: service);

      await viewModel.fetchHoaDons();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
      expect(viewModel.hoaDons, isEmpty);
    });

    test('runAutoBilling and submitBulkMeterReadings execute successfully', () async {
      final service = FakeHoaDonService(list: [testInvoice]);
      final viewModel = HoaDonViewModel(service: service);

      final result = await viewModel.runAutoBilling(7, 2026, 1, toaNhaId: 1);
      expect(result, isNotNull);
      expect(result!['createdCount'], 10);
      expect(result['skippedCount'], 2);

      final meterSuccess = await viewModel.submitBulkMeterReadings(7, 2026, [
        {'canHoId': 1, 'phiDichVuId': 5, 'chiSoCu': 100, 'chiSoMoi': 150}
      ]);
      expect(meterSuccess, isTrue);

      final meteredServices = await viewModel.fetchMeteredServicesForCanHo(1);
      expect(meteredServices, isA<List>());
    });

    test('displayTrangThai evaluates due date accurately', () {
      final now = DateTime.now();
      
      // Due today -> Should NOT be marked overdue today
      final dueToday = HoaDon(
        id: 2,
        maThanhToan: 'HD2',
        canHo: 1,
        soCanHo: '101',
        thang: 7,
        nam: 2026,
        tongTien: 500000.0,
        soTienDaThanhToan: 0.0,
        chiPhi: 500000.0,
        hanThanhToan: now,
        trangThai: 1,
        tenNguoiCapNhat: 'Manager',
        createdAt: now,
        updatedAt: now,
      );
      expect(dueToday.displayTrangThai, 1);

      // Due 2 days ago -> Should be marked overdue
      final pastDue = HoaDon(
        id: 3,
        maThanhToan: 'HD3',
        canHo: 1,
        soCanHo: '101',
        thang: 7,
        nam: 2026,
        tongTien: 500000.0,
        soTienDaThanhToan: 0.0,
        chiPhi: 500000.0,
        hanThanhToan: now.subtract(const Duration(days: 2)),
        trangThai: 1,
        tenNguoiCapNhat: 'Manager',
        createdAt: now,
        updatedAt: now,
      );
      expect(pastDue.displayTrangThai, 3);
    });
  });
}
