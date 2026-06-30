import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';
import 'package:urbano_manage/Services/nhan_vien_service.dart';

class NhanVienViewModel extends ChangeNotifier {
  final NhanVienService _service;

  NhanVienViewModel({NhanVienService? service}) : _service = service ?? NhanVienService();

  List<NhanVien> nhanViens = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchNhanViens() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      nhanViens = await _service.fetchNhanViens();
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách nhân viên';
      nhanViens = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new employee.
  Future<bool> addNhanVien(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final nv = await _service.createNhanVien(data);
      nhanViens.insert(0, nv);
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

  /// Updates an existing employee.
  Future<bool> editNhanVien(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updateNhanVien(id, data);
      if (success) {
        // Refresh local list
        await fetchNhanViens();
        return true;
      }
      error = 'Không thể cập nhật nhân viên';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes an employee.
  Future<bool> removeNhanVien(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deleteNhanVien(id);
      if (success) {
        nhanViens.removeWhere((item) => item.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa nhân viên';
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
