import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';

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
      } else if (currentTab == 1) { // Chưa thanh toán
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 1).toList();
      } else if (currentTab == 2) { // Đã thanh toán
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 3).toList();
      } else if (currentTab == 3) { // 1 phần
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 2).toList();
      } else if (currentTab == 4) { // Quá hạn
        hoaDons = allInvoices.where((h) => h.displayTrangThai == 4).toList();
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

  List<Map<String, dynamic>> buildings = [];

  /// Fetches buildings for form scope dropdowns.
  Future<void> fetchBuildings() async {
    try {
      final response = await _service.fetchHoaDons(); // fallback check
      buildings = [];
    } catch (_) {
      buildings = [];
    }
  }

  /// Runs auto-billing for a specific month/year with optional filters.
  Future<Map<String, dynamic>?> runAutoBilling(
    int thang, 
    int nam, 
    int nguoiTao, {
    int? toaNhaId, 
    DateTime? hanThanhToan,
    List<String>? feeTypes,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.autoBilling(
        thang, 
        nam, 
        nguoiTao, 
        toaNhaId: toaNhaId, 
        hanThanhToan: hanThanhToan,
        feeTypes: feeTypes,
      );
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

  /// Saves meter readings in bulk.
  Future<bool> submitBulkMeterReadings(
    int thang, 
    int nam, 
    List<Map<String, dynamic>> readings,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.saveBulkMeterReadings(thang, nam, readings);
      if (success) {
        await fetchHoaDons();
        return true;
      }
      error = 'Không thể lưu chỉ số điện nước hàng loạt';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches metered service fees for a specific apartment from DB.
  Future<List<Map<String, dynamic>>> fetchMeteredServicesForCanHo(int canHoId) async {
    try {
      final fees = await CanHoService().fetchFeesByCanHoId(canHoId);
      // Filter fees that require meter readings (e.g. unit contains kWh, m3, số or fee name contains điện, nước, gas, chỉ số)
      return fees.where((f) {
        final unit = (f['tenDonViTinh'] as String? ?? '').toLowerCase();
        final name = (f['tenPhiDichVu'] as String? ?? '').toLowerCase();
        return unit.contains('kwh') ||
            unit.contains('m³') ||
            unit.contains('m3') ||
            unit.contains('số') ||
            unit.contains('chỉ số') ||
            name.contains('điện') ||
            name.contains('nước') ||
            name.contains('gas') ||
            name.contains('đo đếm') ||
            name.contains('chỉ số');
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Gets the accurate previous meter reading (chiSoCu) from the latest invoice line for an apartment.
  Future<int> getLatestMeterReading(int canHoId, String tenPhiDichVu) async {
    try {
      if (hoaDons.isEmpty) {
        final all = await _service.fetchHoaDons();
        hoaDons = all;
      }
      final apartmentInvoices = hoaDons.where((h) => h.canHo == canHoId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (apartmentInvoices.isEmpty) return 0;

      final latestInvoice = apartmentInvoices.first;
      final details = await _service.fetchChiTietHoaDons(latestInvoice.id);

      for (var d in details) {
        final serviceName = d['tenPhiDichVu'] as String? ?? '';
        if (serviceName.toLowerCase() == tenPhiDichVu.toLowerCase() ||
            serviceName.toLowerCase().contains(tenPhiDichVu.toLowerCase())) {
          final chiSoMoi = d['chiSoMoi'] as num? ?? d['chiSoCu'] as num? ?? 0;
          return chiSoMoi.toInt();
        }
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
