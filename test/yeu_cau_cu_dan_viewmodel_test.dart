import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/ViewModels/yeu_cau_cu_dan_viewmodel.dart';
import 'package:urbano_manage/Services/yeu_cau_cu_dan_service.dart';
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';

class FakeYeuCauCuDanService extends YeuCauCuDanService {
  final bool shouldFail;
  FakeYeuCauCuDanService({this.shouldFail = false});

  @override
  Future<List<YeuCauCuDan>> fetchYeuCaus({int? trangThai}) async {
    if (shouldFail) throw Exception('API Error');
    return [];
  }

  @override
  Future<bool> deleteYeuCau(int id) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }
}

void main() {
  group('YeuCauCuDanViewModel Tests', () {
    test('removeYeuCau works correctly', () async {
      final service = FakeYeuCauCuDanService();
      final vm = YeuCauCuDanViewModel(service: service);
      
      final mockYeuCau = YeuCauCuDan(
        id: 10,
        cuDan: 1,
        tenCuDan: 'Fake Resident',
        loaiYeuCau: 1,
        tenLoaiYeuCau: 'Fake Type',
        tieuDe: 'Leak',
        noiDung: 'Water leak',
        ngayGui: DateTime.now(),
        mucDoUuTien: 1,
        mucDoUuTienText: 'Thường',
        trangThai: 1,
        trangThaiText: 'Chờ xử lý',
        tenNhanVienXuLy: '',
        tenNguoiCapNhat: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      vm.yeuCaus = [mockYeuCau];

      final deleteOk = await vm.removeYeuCau(10);
      expect(deleteOk, isTrue);
      expect(vm.yeuCaus, isEmpty);
    });
  });
}
