import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';

class HoaDonViewModel extends ChangeNotifier {
  final HoaDonService _service;

  HoaDonViewModel({dynamic service}) : _service = service ?? HoaDonService();

  List<HoaDon> hoaDons = [];
  bool isLoading = false;
  String? error;
  int currentTab = 0; // 0: Tất cả, 1: Chưa thanh toán, 2: Đã thanh toán, 3: 1 phần, 4: Quá hạn

  // Cache for line items of currently selected invoice
  List<Map<String, dynamic>> currentChiTiets = [];

  Future<void> fetchHoaDons() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final allInvoices = await _service.fetchHoaDons();
      allInvoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (currentTab == 0) {
        hoaDons = allInvoices;
      } else if (currentTab == 1) { // Chưa trả
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 1).toList();
      } else if (currentTab == 2) { // Đã trả
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 2).toList();
      } else if (currentTab == 3) { // 1 phần
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 4).toList();
      } else if (currentTab == 4) { // Quá hạn
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 3).toList();
      }
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách hóa đơn';
      hoaDons = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeTab(int index) {
    currentTab = index;
    fetchHoaDons();
  }

  /// Adds a new invoice.
  Future<bool> addHoaDon(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final hd = await _service.createHoaDon(data);
      hoaDons.insert(0, hd);
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

  /// Updates an invoice.
  Future<bool> editHoaDon(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updateHoaDon(id, data);
      if (success) {
        await fetchHoaDons();
        return true;
      }
      error = 'Không thể cập nhật hóa đơn';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes an invoice.
  Future<bool> removeHoaDon(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deleteHoaDon(id);
      if (success) {
        hoaDons.removeWhere((item) => item.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa hóa đơn';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches invoice detail lines (ChiTietHoaDon).
  Future<void> fetchChiTiets(int hoaDonId) async {
    currentChiTiets = [];
    notifyListeners();

    try {
      currentChiTiets = await _service.fetchChiTietHoaDons(hoaDonId);
    } catch (_) {
      currentChiTiets = [];
    } finally {
      notifyListeners();
    }
  }

  /// Adds a detail line item.
  Future<bool> addChiTietItem(int hoaDonId, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.addChiTiet(hoaDonId, data);
      await fetchChiTiets(hoaDonId);
      await fetchHoaDons(); // Refresh list to get updated totals
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Records a payment.
  Future<bool> recordPayment(int hoaDonId, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.payHoaDon(hoaDonId, data);
      if (success) {
        await fetchHoaDons();
        return true;
      }
      error = 'Không thể ghi nhận thanh toán';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Runs auto-billing for a specific month/year.
  Future<Map<String, dynamic>?> runAutoBilling(int thang, int nam, int nguoiTao) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.autoBilling(thang, nam, nguoiTao);
      await fetchHoaDons();
      return result;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
