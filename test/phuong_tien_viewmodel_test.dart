import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/phuong_tien/ViewModels/phuong_tien_viewmodel.dart';
import 'package:urbano_manage/Services/phuong_tien_service.dart';
import 'package:urbano_manage/Models/phuong_tien_model.dart';
import 'package:urbano_manage/Models/loai_phuong_tien_model.dart';

class FakePhuongTienService extends PhuongTienService {
  final List<PhuongTien> list;
  final bool shouldFail;
  FakePhuongTienService({required this.list, this.shouldFail = false});

  @override
  Future<List<PhuongTien>> fetchAll() async {
    if (shouldFail) throw Exception('API Error');
    return list;
  }

  @override
  Future<List<LoaiPhuongTien>> fetchLoaiPhuongTiens() async {
    if (shouldFail) throw Exception('API Error');
    return [LoaiPhuongTien(id: 1, tenLoaiPhuongTien: 'Car')];
  }

  @override
  Future<PhuongTien> create(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('API Error');
    return PhuongTien(
      id: 88,
      tenPhuongTien: data['tenPhuongTien'] as String,
      bienSo: data['bienSo'] as String,
      loaiPhuongTienId: data['loaiPhuongTienId'] as int,
      tenLoaiPhuongTien: 'Car',
      canHoId: data['canHoId'] as int,
      soCanHo: 'A1-101',
      ngayDangKy: DateTime.now(),
      trangThai: data['trangThai'] as int,
      tenNguoiCapNhat: 'Admin',
    );
  }

  @override
  Future<bool> update(int id, Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }
}

void main() {
  group('PhuongTienViewModel Tests', () {
    final sampleVehicle = PhuongTien(
      id: 1,
      tenPhuongTien: 'Honda Civic',
      bienSo: '30F-12345',
      loaiPhuongTienId: 1,
      tenLoaiPhuongTien: 'Car',
      canHoId: 1,
      soCanHo: 'A1-101',
      ngayDangKy: DateTime.now(),
      trangThai: 1,
      tenNguoiCapNhat: 'Admin',
    );

    test('fetchItems and fetchLookups success updates state', () async {
      final service = FakePhuongTienService(list: [sampleVehicle]);
      final vm = PhuongTienViewModel(service: service);

      expect(vm.items, isEmpty);
      expect(vm.vehicleTypes, isEmpty);

      await vm.fetchItems();
      await vm.fetchLookups();

      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.items.length, 1);
      expect(vm.items.first.tenPhuongTien, 'Honda Civic');
      expect(vm.vehicleTypes.length, 1);
      expect(vm.vehicleTypes.first.tenLoaiPhuongTien, 'Car');
    });

    test('addItem, editItem, removeItem work correctly', () async {
      final service = FakePhuongTienService(list: [sampleVehicle]);
      final vm = PhuongTienViewModel(service: service);

      await vm.fetchItems();
      expect(vm.items.length, 1);

      final ok = await vm.addItem({
        'tenPhuongTien': 'Yamaha Exciter',
        'bienSo': '29-X1 9999',
        'loaiPhuongTienId': 2,
        'canHoId': 1,
        'trangThai': 1,
      });
      expect(ok, isTrue);
      expect(vm.items.length, 2);
      expect(vm.items.first.tenPhuongTien, 'Yamaha Exciter');

      final editOk = await vm.editItem(88, {
        'tenPhuongTien': 'Yamaha Exciter New',
        'bienSo': '29-X1 9999',
        'loaiPhuongTienId': 2,
        'canHoId': 1,
        'trangThai': 1,
      });
      expect(editOk, isTrue);

      final removeOk = await vm.removeItem(88);
      expect(removeOk, isTrue);
      expect(vm.items.length, 1);
    });
  });
}
