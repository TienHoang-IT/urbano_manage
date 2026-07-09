import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/thong_bao_model.dart';
import 'package:urbano_manage/Services/thong_bao_service.dart';

class ThongBaoViewModel extends ChangeNotifier {
  final ThongBaoService _service;

  ThongBaoViewModel({ThongBaoService? service}) : _service = service ?? ThongBaoService();

  List<ThongBao> thongBaos = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchThongBaos() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      thongBaos = await _service.fetchThongBaos();
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách thông báo';
      thongBaos = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new notification.
  Future<bool> addThongBao(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final tb = await _service.createThongBao(data);
      thongBaos.insert(0, tb);
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

  /// Updates a notification.
  Future<bool> editThongBao(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updateThongBao(id, data);
      if (success) {
        await fetchThongBaos();
        return true;
      }
      error = 'Không thể cập nhật thông báo';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a notification.
  Future<bool> removeThongBao(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deleteThongBao(id);
      if (success) {
        thongBaos.removeWhere((item) => item.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa thông báo';
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
