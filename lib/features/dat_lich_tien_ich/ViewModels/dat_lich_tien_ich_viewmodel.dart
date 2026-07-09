import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/Services/dat_lich_tien_ich_service.dart';
import 'package:urbano_manage/Services/tien_ich_service.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';

class DatLichTienIchViewModel extends ChangeNotifier {
  final DatLichTienIchService _service;
  final TienIchService _tienIchService;
  final CuDanService _cuDanService;
  final CanHoService _canHoService;

  DatLichTienIchViewModel({
    DatLichTienIchService? service,
    TienIchService? tienIchService,
    CuDanService? cuDanService,
    CanHoService? canHoService,
  })  : _service = service ?? DatLichTienIchService(),
        _tienIchService = tienIchService ?? TienIchService(),
        _cuDanService = cuDanService ?? CuDanService(),
        _canHoService = canHoService ?? CanHoService();

  bool isLoading = false;
  String? error;
  List<DatLichTienIch> bookings = [];
  int currentTab = 0; // 0: Tất cả, 1: Chờ duyệt, 2: Đã duyệt, 3: Từ chối, 4: Đã hủy, 5: Hoàn thành

  // Preloaded dropdown data for forms
  List<TienIch> utilities = [];
  List<CuDan> residents = [];
  List<CanHo> apartments = [];

  Future<void> fetchBookings() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final allBookings = await _service.fetchAll();
      if (currentTab == 0) {
        bookings = allBookings;
      } else {
        // Tab mapping directly matches trangThai: 1=Chờ duyệt, 2=Đã duyệt, 3=Từ chối, 4=Đã hủy, 5=Hoàn thành
        bookings = allBookings.where((element) => element.trangThai == currentTab).toList();
      }
      // Sort newest first
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      error = null;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      bookings = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeTab(int tabIndex) {
    currentTab = tabIndex;
    fetchBookings();
  }

  Future<void> loadFormDropdowns() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tienIchService.fetchTienIchs(),
        _cuDanService.fetchCuDans(),
        _canHoService.fetchCanHos(),
      ]);

      utilities = results[0] as List<TienIch>;
      residents = results[1] as List<CuDan>;
      apartments = results[2] as List<CanHo>;
      error = null;
    } catch (e) {
      error = 'Không thể tải dữ liệu danh mục phụ';
      debugPrint('Error loading form dropdowns: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final created = await _service.create(data);
      bookings.insert(0, created);
      error = null;
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveBooking(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.duyet(id, 2, null);
      if (success) {
        await fetchBookings();
        error = null;
        return true;
      }
      error = 'Duyệt đặt lịch thất bại';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectBooking(int id, String lyDoHuy) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.duyet(id, 3, lyDoHuy);
      if (success) {
        await fetchBookings();
        error = null;
        return true;
      }
      error = 'Từ chối đặt lịch thất bại';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.huy(id);
      if (success) {
        await fetchBookings();
        error = null;
        return true;
      }
      error = 'Hủy đặt lịch thất bại';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBooking(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.delete(id);
      if (success) {
        bookings.removeWhere((element) => element.id == id);
        error = null;
        return true;
      }
      error = 'Xóa đặt lịch thất bại';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
