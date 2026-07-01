import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/ViewModels/yeu_cau_cu_dan_viewmodel.dart';
import 'package:urbano_manage/Services/yeu_cau_cu_dan_service.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Services/nhan_vien_service.dart';
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';
import 'package:urbano_manage/Models/loai_yeu_cau_model.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';

class FakeYeuCauCuDanService extends YeuCauCuDanService {
  final bool shouldFail;
  FakeYeuCauCuDanService({this.shouldFail = false});

  @override
  Future<List<YeuCauCuDan>> fetchYeuCaus({int? trangThai}) async {
    if (shouldFail) throw Exception('API Error');
    return [];
  }

  @override
  Future<List<LoaiYeuCau>> fetchLoaiYeuCaus() async {
    if (shouldFail) throw Exception('API Error');
    return [LoaiYeuCau(id: 1, name: 'Fake Type')];
  }

  @override
  Future<YeuCauCuDan> createYeuCau(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('API Error');
    return YeuCauCuDan(
      id: 10,
      cuDan: data['cuDan'] as int,
      tenCuDan: 'Fake Resident',
      loaiYeuCau: data['loaiYeuCau'] as int,
      tenLoaiYeuCau: 'Fake Type',
      tieuDe: data['tieuDe'] as String,
      noiDung: data['noiDung'] as String,
      ngayGui: DateTime.now(),
      mucDoUuTien: data['mucDoUuTien'] as int,
      mucDoUuTienText: 'Thường',
      trangThai: data['trangThai'] as int,
      trangThaiText: 'Chờ xử lý',
      tenNhanVienXuLy: '',
      tenNguoiCapNhat: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteYeuCau(int id) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }
}

class FakeCuDanService extends CuDanService {
  @override
  Future<List<CuDan>> fetchCuDans() async {
    return [
      CuDan(
        id: 1,
        hoTenDem: 'Nguyen Van',
        ten: 'A',
        hoTen: 'Nguyen Van A',
        sdt: '123',
        cccd: '123',
        email: 'a@mail.com',
        gioiTinhText: 'Nam',
        tinh: 'HN',
        xa: 'CG',
        diaChi: '123',
        diaChiDayDu: '123 HN',
        trangThai: 1,
        trangThaiText: 'Hoạt động',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  }
}

class FakeNhanVienService extends NhanVienService {
  @override
  Future<List<NhanVien>> fetchNhanViens() async {
    return [
      NhanVien(
        id: 1,
        hoTen: 'Staff 1',
        maNhanVien: 'NV001',
        chucVu: 1,
        sdt: '123',
        email: 'staff@mail.com',
        cccd: '123',
        ghiChu: '',
        trangThai: 1,
      )
    ];
  }
}

void main() {
  group('YeuCauCuDanViewModel Tests', () {
    test('loadFormDropdowns preloads dropdowns correctly', () async {
      final service = FakeYeuCauCuDanService();
      final cuDanService = FakeCuDanService();
      final nhanVienService = FakeNhanVienService();
      
      final vm = YeuCauCuDanViewModel(
        service: service,
        cuDanService: cuDanService,
        nhanVienService: nhanVienService,
      );

      expect(vm.cuDans, isEmpty);
      expect(vm.loaiYeuCaus, isEmpty);
      expect(vm.nhanViens, isEmpty);

      await vm.loadFormDropdowns();

      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.cuDans.length, 1);
      expect(vm.loaiYeuCaus.length, 1);
      expect(vm.nhanViens.length, 1);
    });

    test('addYeuCau and removeYeuCau work correctly', () async {
      final service = FakeYeuCauCuDanService();
      final vm = YeuCauCuDanViewModel(service: service);

      expect(vm.yeuCaus, isEmpty);

      final ok = await vm.addYeuCau({
        'cuDan': 1,
        'loaiYeuCau': 1,
        'tieuDe': 'Leak',
        'noiDung': 'Water leak',
        'mucDoUuTien': 2,
        'trangThai': 1,
      });

      expect(ok, isTrue);
      expect(vm.yeuCaus.length, 1);
      expect(vm.yeuCaus.first.tieuDe, 'Leak');

      final deleteOk = await vm.removeYeuCau(10);
      expect(deleteOk, isTrue);
      expect(vm.yeuCaus, isEmpty);
    });
  });
}
