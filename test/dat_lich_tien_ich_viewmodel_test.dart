import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/ViewModels/dat_lich_tien_ich_viewmodel.dart';
import 'package:urbano_manage/Services/dat_lich_tien_ich_service.dart';
import 'package:urbano_manage/Services/tien_ich_service.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';
import 'package:urbano_manage/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';

class FakeDatLichTienIchService extends DatLichTienIchService {
  final bool shouldFail;
  FakeDatLichTienIchService({this.shouldFail = false});

  @override
  Future<List<DatLichTienIch>> fetchAll() async {
    if (shouldFail) throw Exception('API Error');
    return [
      DatLichTienIch(
        id: 1,
        maDatLich: 'DL001',
        cuDanId: 1,
        tenCuDan: 'Nguyen Van A',
        canHoId: 1,
        soCanHo: 'A101',
        tienIchId: 1,
        tenTienIch: 'Sân bóng',
        thoiGianBatDau: DateTime.now(),
        thoiGianKetThuc: DateTime.now().add(const Duration(hours: 1)),
        soNguoi: 10,
        phiSuDung: 50000,
        ghiChu: 'Ghi chu 1',
        trangThai: 1, // Chờ duyệt
        trangThaiText: 'Chờ duyệt',
        tenNhanVienDuyet: '',
        lyDoHuy: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DatLichTienIch(
        id: 2,
        maDatLich: 'DL002',
        cuDanId: 1,
        tenCuDan: 'Nguyen Van A',
        canHoId: 1,
        soCanHo: 'A101',
        tienIchId: 1,
        tenTienIch: 'Sân bóng',
        thoiGianBatDau: DateTime.now(),
        thoiGianKetThuc: DateTime.now().add(const Duration(hours: 1)),
        soNguoi: 10,
        phiSuDung: 50000,
        ghiChu: 'Ghi chu 2',
        trangThai: 2, // Đã duyệt
        trangThaiText: 'Đã duyệt',
        tenNhanVienDuyet: 'NV A',
        lyDoHuy: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  }

  @override
  Future<DatLichTienIch> getById(int id) async {
    if (shouldFail) throw Exception('API Error');
    return DatLichTienIch(
      id: id,
      maDatLich: 'DL00$id',
      cuDanId: 1,
      tenCuDan: 'Nguyen Van A',
      canHoId: 1,
      soCanHo: 'A101',
      tienIchId: 1,
      tenTienIch: 'Sân bóng',
      thoiGianBatDau: DateTime.now(),
      thoiGianKetThuc: DateTime.now().add(const Duration(hours: 1)),
      soNguoi: 10,
      phiSuDung: 50000,
      ghiChu: '',
      trangThai: 2, // Approved state return on reload
      trangThaiText: 'Đã duyệt',
      tenNhanVienDuyet: 'NV A',
      lyDoHuy: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<DatLichTienIch> create(Map<String, dynamic> data) async {
    if (shouldFail) throw Exception('API Error');
    return DatLichTienIch(
      id: 3,
      maDatLich: 'DL003',
      cuDanId: data['cuDanId'] as int,
      tenCuDan: 'Nguyen Van A',
      canHoId: data['canHoId'] as int?,
      soCanHo: 'A101',
      tienIchId: data['tienIchId'] as int,
      tenTienIch: 'Sân bóng',
      thoiGianBatDau: DateTime.parse(data['thoiGianBatDau'] as String),
      thoiGianKetThuc: DateTime.parse(data['thoiGianKetThuc'] as String),
      soNguoi: data['soNguoi'] as int,
      phiSuDung: 50000,
      ghiChu: data['ghiChu'] as String? ?? '',
      trangThai: 1,
      trangThaiText: 'Chờ duyệt',
      tenNhanVienDuyet: '',
      lyDoHuy: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> duyet(int id, int trangThai, String? lyDoHuy) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }

  @override
  Future<bool> huy(int id) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    if (shouldFail) throw Exception('API Error');
    return true;
  }
}

class FakeTienIchService extends TienIchService {
  @override
  Future<List<TienIch>> fetchTienIchs() async {
    return [
      TienIch(
        id: 1,
        tenTienIch: 'Sân bóng',
        loaiTienIchId: 1,
        tenLoaiTienIch: 'Thể thao',
        toaNhaId: 1,
        tenToaNha: 'Tòa A',
        moTa: '',
        viTri: 'Sân sau',
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
        sdt: '',
        cccd: '',
        email: '',
        gioiTinhText: 'Nam',
        tinh: '',
        xa: '',
        diaChi: '',
        diaChiDayDu: '',
        trangThai: 1,
        trangThaiText: 'Hoạt động',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  }
}

class FakeCanHoService extends CanHoService {
  @override
  Future<List<CanHo>> fetchCanHos() async {
    return [
      CanHo(
        id: 1,
        soCanHo: 'A101',
        toaNhaId: 1,
        tenToaNha: 'Tòa A',
        tang: 1,
        loaiCanHoId: 1,
        tenLoaiCanHo: 'Chung cư',
        trangThaiId: 1,
        tenTrangThai: 'Có người ở',
        tenNguoiCapNhat: 'Staff',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  }
}

void main() {
  group('DatLichTienIchViewModel Tests', () {
    test('fetchBookings correctly filters tab', () async {
      final service = FakeDatLichTienIchService();
      final vm = DatLichTienIchViewModel(service: service);

      expect(vm.bookings, isEmpty);

      // All
      await vm.fetchBookings();
      expect(vm.bookings.length, 2);

      // Filter: Chờ duyệt (currentTab = 1)
      vm.changeTab(1);
      await vm.fetchBookings();
      expect(vm.bookings.length, 1);
      expect(vm.bookings.first.trangThai, 1);

      // Filter: Đã duyệt (currentTab = 2)
      vm.changeTab(2);
      await vm.fetchBookings();
      expect(vm.bookings.length, 1);
      expect(vm.bookings.first.trangThai, 2);
    });

    test('loadFormDropdowns preloads data correctly', () async {
      final service = FakeDatLichTienIchService();
      final tienIchService = FakeTienIchService();
      final cuDanService = FakeCuDanService();
      final canHoService = FakeCanHoService();
      final vm = DatLichTienIchViewModel(
        service: service,
        tienIchService: tienIchService,
        cuDanService: cuDanService,
        canHoService: canHoService,
      );

      expect(vm.utilities, isEmpty);
      expect(vm.residents, isEmpty);
      expect(vm.apartments, isEmpty);

      await vm.loadFormDropdowns();
      expect(vm.utilities.length, 1);
      expect(vm.residents.length, 1);
      expect(vm.apartments.length, 1);
      expect(vm.utilities.first.tenTienIch, 'Sân bóng');
    });

    test('booking operations like create, approve, reject, cancel, and delete work correctly', () async {
      final service = FakeDatLichTienIchService();
      final vm = DatLichTienIchViewModel(service: service);

      // Create booking
      final addOk = await vm.createBooking({
        'cuDanId': 1,
        'canHoId': 1,
        'tienIchId': 1,
        'thoiGianBatDau': DateTime.now().toIso8601String(),
        'thoiGianKetThuc': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'soNguoi': 5,
        'ghiChu': 'Test note',
      });
      expect(addOk, isTrue);
      expect(vm.bookings.length, 1);
      expect(vm.bookings.first.id, 3);

      // Approve
      final duyetOk = await vm.approveBooking(3);
      expect(duyetOk, isTrue);

      // Reject
      final tuChoiOk = await vm.rejectBooking(3, 'Trùng lịch');
      expect(tuChoiOk, isTrue);

      // Cancel
      final huyOk = await vm.cancelBooking(3);
      expect(huyOk, isTrue);

      // Delete booking with id: 1 (which was loaded by approve/reject/cancel calls)
      final deleteOk = await vm.deleteBooking(1);
      expect(deleteOk, isTrue);
      expect(vm.bookings.any((b) => b.id == 1), isFalse);
    });
  });
}
