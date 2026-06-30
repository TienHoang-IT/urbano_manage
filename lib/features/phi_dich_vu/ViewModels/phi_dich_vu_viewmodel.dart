import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/phi_dich_vu_model.dart';
import 'package:urbano_manage/Services/phi_dich_vu_service.dart';

class PhiDichVuViewModel extends ChangeNotifier {
  final PhiDichVuService _service;

  PhiDichVuViewModel({PhiDichVuService? service}) : _service = service ?? PhiDichVuService();

  List<PhiDichVu> phiDichVus = [];
  bool isLoading = false;
  String? error;

  // Lookups
  List<Map<String, dynamic>> feeTypes = [];
  List<Map<String, dynamic>> unitTypes = [];
  List<Map<String, dynamic>> calcTypes = [];

  Future<void> fetchPhiDichVus() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      phiDichVus = await _service.fetchPhiDichVus();
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách phí dịch vụ';
      phiDichVus = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLookups() async {
    try {
      final results = await Future.wait([
        _service.fetchLoaiPhiDichVus(),
        _service.fetchDonViTinhs(),
        _service.fetchLoaiTinhPhis(),
      ]);
      feeTypes = results[0];
      unitTypes = results[1];
      calcTypes = results[2];
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching lookups for PhiDichVu: $e');
    }
  }

  /// Adds a new service fee.
  Future<bool> addPhiDichVu(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final pdv = await _service.createPhiDichVu(data);
      phiDichVus.insert(0, pdv);
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

  /// Updates a service fee.
  Future<bool> editPhiDichVu(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updatePhiDichVu(id, data);
      if (success) {
        await fetchPhiDichVus();
        return true;
      }
      error = 'Không thể cập nhật thông tin phí dịch vụ';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a service fee.
  Future<bool> removePhiDichVu(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deletePhiDichVu(id);
      if (success) {
        phiDichVus.removeWhere((item) => item.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa phí dịch vụ';
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
