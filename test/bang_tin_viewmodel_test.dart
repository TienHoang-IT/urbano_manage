import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/bang_tin/ViewModels/bang_tin_viewmodel.dart';
import 'package:urbano_manage/Services/bang_tin_service.dart';
import 'package:urbano_manage/Models/bang_tin_model.dart';

class FakeBangTinService extends BangTinService {
  final List<BangTin> list;
  final bool shouldFail;
  FakeBangTinService({required this.list, this.shouldFail = false});

  @override
  Future<List<BangTin>> fetchAll() async {
    if (shouldFail) throw Exception('API Error');
    return list;
  }

  @override
  Future<BangTin> create(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('API Error');
    return BangTin(
      id: 99,
      tieuDe: data['tieuDe'] as String,
      noiDung: data['noiDung'] as String,
      hinhUrl: data['hinhUrl'] as String,
      nguoiTaoId: 1,
      tenNguoiTao: 'Admin',
      nguoiCapNhatId: 1,
      tenNguoiCapNhat: 'Admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
  group('BangTinViewModel Tests', () {
    final sampleNews = BangTin(
      id: 1,
      tieuDe: 'Title 1',
      noiDung: 'Content 1',
      hinhUrl: 'url',
      nguoiTaoId: 1,
      tenNguoiTao: 'Admin',
      nguoiCapNhatId: 1,
      tenNguoiCapNhat: 'Admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('fetchItems success updates state', () async {
      final service = FakeBangTinService(list: [sampleNews]);
      final vm = BangTinViewModel(service: service);

      expect(vm.items, isEmpty);
      await vm.fetchItems();

      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.items.length, 1);
      expect(vm.items.first.tieuDe, 'Title 1');
    });

    test('addItem, editItem, removeItem work correctly', () async {
      final service = FakeBangTinService(list: [sampleNews]);
      final vm = BangTinViewModel(service: service);

      await vm.fetchItems();
      expect(vm.items.length, 1);

      final ok = await vm.addItem({
        'tieuDe': 'New Title',
        'noiDung': 'New Content',
        'hinhUrl': '',
      });
      expect(ok, isTrue);
      expect(vm.items.length, 2);
      expect(vm.items.first.tieuDe, 'New Title');

      final editOk = await vm.editItem(99, {
        'tieuDe': 'Updated Title',
        'noiDung': 'Updated Content',
        'hinhUrl': '',
      });
      expect(editOk, isTrue);

      final removeOk = await vm.removeItem(99);
      expect(removeOk, isTrue);
      expect(vm.items.length, 1);
    });
  });
}
