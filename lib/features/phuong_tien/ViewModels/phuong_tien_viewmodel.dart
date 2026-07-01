import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/phuong_tien_model.dart';
import 'package:urbano_manage/Models/loai_phuong_tien_model.dart';
import 'package:urbano_manage/Services/phuong_tien_service.dart';

class PhuongTienViewModel extends ChangeNotifier {
  final PhuongTienService _service;

  PhuongTienViewModel({PhuongTienService? service}) : _service = service ?? PhuongTienService();

  List<PhuongTien> items = [];
  List<LoaiPhuongTien> vehicleTypes = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchItems() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      items = await _service.fetchAll();
      error = null;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLookups() async {
    try {
      vehicleTypes = await _service.fetchLoaiPhuongTiens();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching vehicle type lookups: $e');
    }
  }

  Future<bool> addItem(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final newItem = await _service.create(data);
      items.insert(0, newItem);
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

  Future<bool> editItem(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.update(id, data);
      if (success) {
        await fetchItems();
        return true;
      }
      error = 'Không thể cập nhật phương tiện';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeItem(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.delete(id);
      if (success) {
        items.removeWhere((item) => item.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa phương tiện';
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
