import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/cu_dan/ViewModels/cu_dan_viewmodel.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';

class FakeCuDanService extends CuDanService {
  final List<CuDan> list;
  final bool shouldFail;
  Map<String, dynamic>? lastCreatedData;

  FakeCuDanService({required this.list, this.shouldFail = false});

  @override
  Future<List<CuDan>> fetchCuDans() async {
    if (shouldFail) throw Exception('Failed to fetch');
    return list;
  }

  @override
  Future<CuDan> createCuDan(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('Failed to create');
    lastCreatedData = data;
    return CuDan(
      id: 99,
      hoTenDem: data['hoTenDem'] ?? '',
      ten: data['ten'] ?? '',
      hoTen: '${data['hoTenDem']} ${data['ten']}',
      sdt: data['sdt'] ?? '',
      cccd: data['cccd'] ?? '',
      email: data['email'] ?? '',
      gioiTinhText: 'Nam',
      tinh: data['tinh'] ?? '',
      xa: data['xa'] ?? '',
      diaChi: data['diaChi'] ?? '',
      diaChiDayDu: '',
      trangThai: data['trangThai'] ?? 2,
      trangThaiText: 'Đang cư trú',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> updateCuDan(int id, Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('Failed to update');
    return true;
  }

  @override
  Future<bool> deleteCuDan(int id) async {
    if (shouldFail) throw Exception('Failed to delete');
    return true;
  }
}

void main() {
  group('CuDanViewModel Tests', () {
    final testResident = CuDan(
      id: 1,
      hoTenDem: 'Nguyễn Văn',
      ten: 'A',
      hoTen: 'Nguyễn Văn A',
      sdt: '0123456789',
      cccd: '123456789',
      email: 'a@gmail.com',
      gioiTinhText: 'Nam',
      tinh: 'Hà Nội',
      xa: 'Mễ Trì',
      diaChi: 'Số 1',
      diaChiDayDu: 'Số 1, Mễ Trì, Hà Nội',
      trangThai: 2,
      trangThaiText: 'Đang cư trú',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('fetchCuDans success updates state', () async {
      final service = FakeCuDanService(list: [testResident]);
      final viewModel = CuDanViewModel(service: service);

      expect(viewModel.cuDans, isEmpty);
      await viewModel.fetchCuDans();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.cuDans.length, 1);
      expect(viewModel.cuDans.first.hoTen, 'Nguyễn Văn A');
    });

    test('fetchCuDans failure updates error', () async {
      final service = FakeCuDanService(list: [], shouldFail: true);
      final viewModel = CuDanViewModel(service: service);

      await viewModel.fetchCuDans();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
      expect(viewModel.cuDans, isEmpty);
    });

    test('addCuDan success passes correct data including verified status = 2', () async {
      final service = FakeCuDanService(list: [testResident]);
      final viewModel = CuDanViewModel(service: service);

      final success = await viewModel.addCuDan({
        'hoTenDem': 'Trần Thị',
        'ten': 'B',
        'trangThai': 2,
        'tinh': 'Thành phố Hà Nội',
        'xa': 'Phường Ba Đình',
      });

      expect(success, isTrue);
      expect(viewModel.error, isNull);
      expect(service.lastCreatedData?['trangThai'], 2);
      expect(service.lastCreatedData?['tinh'], 'Thành phố Hà Nội');
      expect(service.lastCreatedData?['xa'], 'Phường Ba Đình');
    });

    test('editCuDan success calls fetch', () async {
      final service = FakeCuDanService(list: [testResident]);
      final viewModel = CuDanViewModel(service: service);

      final success = await viewModel.editCuDan(1, {
        'hoTenDem': 'Nguyễn Văn',
        'ten': 'A updated',
      });

      expect(success, isTrue);
      expect(viewModel.error, isNull);
    });

    test('removeCuDan success calls fetch', () async {
      final service = FakeCuDanService(list: []);
      final viewModel = CuDanViewModel(service: service);

      final success = await viewModel.removeCuDan(1);

      expect(success, isTrue);
      expect(viewModel.error, isNull);
      expect(viewModel.cuDans, isEmpty);
    });
  });
}
