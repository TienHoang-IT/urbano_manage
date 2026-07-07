import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/lich_su_thanh_toan/ViewModels/lich_su_thanh_toan_viewmodel.dart';
import 'package:urbano_manage/Services/lich_su_thanh_toan_service.dart';
import 'package:urbano_manage/Models/lich_su_thanh_toan_model.dart';

class FakeLichSuThanhToanService extends LichSuThanhToanService {
  final List<LichSuThanhToan> list;
  final bool shouldFail;

  FakeLichSuThanhToanService({required this.list, this.shouldFail = false});

  @override
  Future<List<LichSuThanhToan>> fetchAll() async {
    if (shouldFail) throw Exception('Failed to fetch');
    return list;
  }
}

void main() {
  group('LichSuThanhToanViewModel', () {
    late FakeLichSuThanhToanService mockService;
    late LichSuThanhToanViewModel viewModel;

    setUp(() {
      mockService = FakeLichSuThanhToanService(list: [
        LichSuThanhToan(
          id: 1,
          hoaDonId: 101,
          maThanhToan: 'TT001',
          thang: 7,
          nam: 2026,
          ngayThanhToan: DateTime(2026, 7, 7),
          soTien: 500000,
          phuongThucThanhToan: 'Tiền mặt',
          maGiaoDich: 'GD001',
          ghiChu: 'Thanh toán phí dịch vụ',
        ),
      ]);
      viewModel = LichSuThanhToanViewModel(service: mockService);
    });

    test('fetchHistories updates state correctly on success', () async {
      expect(viewModel.isLoading, false);
      
      final future = viewModel.fetchHistories();
      expect(viewModel.isLoading, true);
      
      await future;

      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
      expect(viewModel.histories.length, 1);
      expect(viewModel.histories.first.maThanhToan, 'TT001');
    });

    test('fetchHistories updates state correctly on failure', () async {
      mockService = FakeLichSuThanhToanService(list: [], shouldFail: true);
      viewModel = LichSuThanhToanViewModel(service: mockService);

      await viewModel.fetchHistories();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Failed to fetch'));
      expect(viewModel.histories.isEmpty, true);
    });
  });
}
