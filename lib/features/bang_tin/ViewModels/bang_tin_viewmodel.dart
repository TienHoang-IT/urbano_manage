import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/bang_tin_model.dart';
import 'package:urbano_manage/Services/bang_tin_service.dart';

class BangTinViewModel extends ChangeNotifier {
  final BangTinService _service;

  BangTinViewModel({BangTinService? service}) : _service = service ?? BangTinService();

  List<BangTin> items = [];
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

  Future<bool> addItem(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final item = await _service.create(data);
      items.insert(0, item);
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
      error = 'Không thể cập nhật bảng tin';
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
        items.removeWhere((x) => x.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa bảng tin';
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
