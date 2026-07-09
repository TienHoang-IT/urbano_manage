import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/tien_ich/ViewModels/tien_ich_viewmodel.dart';
import 'package:urbano_manage/Services/tien_ich_service.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';

class FakeTienIchService extends TienIchService {
  final bool shouldFail;
  FakeTienIchService({this.shouldFail = false});

  @override
  Future<List<TienIch>> fetchTienIchs() async {
    if (shouldFail) throw Exception('API Error');
    return [
      TienIch(
        id: 1,
        tenTienIch: 'Sân bóng',
        loaiTienIchId: 1,
        tenLoaiTienIch: 'Thể thao',
        toaNhaId: 1,
        tenToaNha: 'Tòa A',
        moTa: 'Sân bóng cỏ nhân tạo',
        viTri: 'Sân sau',
        sucChua: 20,
        phiSuDung: 50000,
        canDatTruoc: true,
        hinhUrl: '',
        trangThai: 1,
        trangThaiText: 'Hoạt động',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  }

  @override
  Future<TienIch> getById(int id) async {
    if (shouldFail) throw Exception('API Error');
    return TienIch(
      id: id,
      tenTienIch: 'Sân bóng cập nhật',
      loaiTienIchId: 1,
      tenLoaiTienIch: 'Thể thao',
      toaNhaId: 1,
      tenToaNha: 'Tòa A',
      moTa: 'Sân bóng cỏ nhân tạo',
      viTri: 'Sân sau',
      sucChua: 20,
      phiSuDung: 50000,
      canDatTruoc: true,
      hinhUrl: '',
      trangThai: 1,
      trangThaiText: 'Hoạt động',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<TienIch> createTienIch(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('API Error');
    return TienIch(
      id: 2,
      tenTienIch: data['tenTienIch'] as String,
      loaiTienIchId: data['loaiTienIch'] as int,
      tenLoaiTienIch: 'Thể thao',
      toaNhaId: data['toaNha'] as int?,
      tenToaNha: 'Tòa A',
      moTa: data['moTa'] as String? ?? '',
      viTri: data['viTri'] as String? ?? '',
      sucChua: data['sucChua'] as int?,
      phiSuDung: (data['phiSuDung'] as num).toDouble(),
      canDatTruoc: data['canDatTruoc'] as bool,
      hinhUrl: data['hinhUrl'] as String? ?? '',
      trangThai: data['trangThai'] as int,
      trangThaiText: 'Hoạt động',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> updateTienIch(int id, Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }

  @override
  Future<bool> deleteTienIch(int id) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLoaiTienIchs() async {
    if (shouldFail) throw Exception('API Error');
    return [
      {'id': 1, 'tenLoaiTienIch': 'Thể thao'}
    ];
  }
}

class FakeCanHoService extends CanHoService {
  @override
  Future<List<Map<String, dynamic>>> fetchToaNhas() async {
    return [
      {'id': 1, 'tenToaNha': 'Tòa A'}
    ];
  }
}

void main() {
  group('TienIchViewModel Tests', () {
    test('fetchTienIchs populates items correctly', () async {
      final service = FakeTienIchService();
      final vm = TienIchViewModel(service: service);

      expect(vm.items, isEmpty);
      await vm.fetchTienIchs();
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.items.length, 1);
      expect(vm.items.first.tenTienIch, 'Sân bóng');
    });

    test('searchQuery filters items correctly', () async {
      final service = FakeTienIchService();
      final vm = TienIchViewModel(service: service);

      await vm.fetchTienIchs();
      expect(vm.filteredItems.length, 1);

      vm.setSearchQuery('bóng');
      expect(vm.filteredItems.length, 1);

      vm.setSearchQuery('bể bơi');
      expect(vm.filteredItems, isEmpty);
    });

    test('loadFormDropdowns preloads data correctly', () async {
      final service = FakeTienIchService();
      final canHoService = FakeCanHoService();
      final vm = TienIchViewModel(service: service, canHoService: canHoService);

      expect(vm.loaiTienIchs, isEmpty);
      expect(vm.toaNhas, isEmpty);

      await vm.loadFormDropdowns();
      expect(vm.loaiTienIchs.length, 1);
      expect(vm.toaNhas.length, 1);
      expect(vm.loaiTienIchs.first['tenLoaiTienIch'], 'Thể thao');
    });

    test('create, update, and delete utility operations work correctly', () async {
      final service = FakeTienIchService();
      final vm = TienIchViewModel(service: service);

      // Create
      final addOk = await vm.create({
        'tenTienIch': 'Bể bơi',
        'loaiTienIch': 1,
        'toaNha': 1,
        'moTa': 'Bể bơi 4 mùa',
        'viTri': 'Tầng 5',
        'phiSuDung': 30000,
        'canDatTruoc': true,
        'trangThai': 1,
      });
      expect(addOk, isTrue);
      expect(vm.items.length, 1);
      expect(vm.items.first.tenTienIch, 'Bể bơi');

      // Update
      final updateOk = await vm.update(2, {
        'tenTienIch': 'Bể bơi cập nhật',
        'loaiTienIch': 1,
        'toaNha': 1,
        'moTa': 'Bể bơi 4 mùa',
        'viTri': 'Tầng 5',
        'phiSuDung': 30000,
        'canDatTruoc': true,
        'trangThai': 1,
      });
      expect(updateOk, isTrue);
      expect(vm.items.first.tenTienIch, 'Sân bóng cập nhật'); // from getById mock return

      // Delete
      final deleteOk = await vm.delete(2);
      expect(deleteOk, isTrue);
      expect(vm.items, isEmpty);
    });
  });
}
