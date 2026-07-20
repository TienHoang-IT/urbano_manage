import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/Models/phi_dich_vu_model.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';
import 'package:urbano_manage/Services/phi_dich_vu_service.dart';

class CanHoViewModel extends ChangeNotifier {
  final CanHoService _service;

  CanHoViewModel({CanHoService? service}) : _service = service ?? CanHoService();

  List<CanHo> canHos = [];
  bool isLoading = false;
  String? error;

  // Lookups
  List<Map<String, dynamic>> buildings = [];
  List<Map<String, dynamic>> roomTypes = [];
  List<Map<String, dynamic>> roomStatuses = [];
  List<PhiDichVu> serviceFees = [];

  Future<void> fetchCanHos() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      canHos = await _service.fetchCanHos();
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách căn hộ';
      canHos = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLookups() async {
    try {
      final results = await Future.wait([
        _service.fetchToaNhas(),
        _service.fetchLoaiCanHos(),
        _service.fetchTrangThaiCanHos(),
        PhiDichVuService().fetchPhiDichVus(),
      ]);
      buildings = results[0] as List<Map<String, dynamic>>;
      roomTypes = results[1] as List<Map<String, dynamic>>;
      roomStatuses = results[2] as List<Map<String, dynamic>>;
      serviceFees = results[3] as List<PhiDichVu>;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching lookups: $e');
    }
  }

  /// Adds a new apartment.
  Future<bool> addCanHo(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final ch = await _service.createCanHo(data);
      canHos.insert(0, ch);
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

  /// Updates an apartment.
  Future<bool> editCanHo(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updateCanHo(id, data);
      if (success) {
        await fetchCanHos();
        return true;
      }
      error = 'Không thể cập nhật thông tin căn hộ';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes an apartment.
  Future<bool> removeCanHo(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deleteCanHo(id);
      if (success) {
        canHos.removeWhere((item) => item.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa căn hộ';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches fees for a specific apartment.
  Future<List<Map<String, dynamic>>> getFeesForCanHo(int canHoId) async {
    try {
      final fees = await _service.fetchFeesByCanHoId(canHoId);
      for (var fee in fees) {
        if (fee['tenDonViTinh'] == null || fee['tenDonViTinh'] == '') {
          final phiDichVuId = fee['phiDichVuId'];
          if (phiDichVuId != null) {
            final match = serviceFees.where((f) => f.id == phiDichVuId).toList();
            if (match.isNotEmpty) {
              fee['tenDonViTinh'] = match.first.tenDonViTinh;
            }
          }
        }
      }
      return fees;
    } catch (e) {
      debugPrint('Error fetching fees: $e');
      return [];
    }
  }
}
