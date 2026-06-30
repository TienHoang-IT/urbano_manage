import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';

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
      ]);
      buildings = results[0];
      roomTypes = results[1];
      roomStatuses = results[2];
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
}
