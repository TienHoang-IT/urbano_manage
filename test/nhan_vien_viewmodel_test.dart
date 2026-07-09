import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/nhan_vien/ViewModels/nhan_vien_viewmodel.dart';
import 'package:urbano_manage/Services/nhan_vien_service.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';

class FakeNhanVienService extends NhanVienService {
  final List<NhanVien> list;
  final bool shouldFail;

  FakeNhanVienService({required this.list, this.shouldFail = false});

  @override
  Future<List<NhanVien>> fetchNhanViens() async {
    if (shouldFail) throw Exception('Failed to fetch');
    return list;
  }
}

void main() {
  group('NhanVienViewModel Tests', () {
    final testEmployee = NhanVien(
      id: 1,
      hoTen: 'Admin Name',
      chucVu: 1,
      sdt: '0123456789',
      email: 'admin@urbano.vn',
      trangThai: 1,
      maNhanVien: 'NV001',
      cccd: '123456789',
      ghiChu: 'Ghi chu',
    );

    test('fetchNhanViens success updates state', () async {
      final service = FakeNhanVienService(list: [testEmployee]);
      final viewModel = NhanVienViewModel(service: service);

      expect(viewModel.nhanViens, isEmpty);
      await viewModel.fetchNhanViens();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.nhanViens.length, 1);
      expect(viewModel.nhanViens.first.hoTen, 'Admin Name');
    });

    test('fetchNhanViens failure updates error', () async {
      final service = FakeNhanVienService(list: [], shouldFail: true);
      final viewModel = NhanVienViewModel(service: service);

      await viewModel.fetchNhanViens();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
      expect(viewModel.nhanViens, isEmpty);
    });
  });
}
