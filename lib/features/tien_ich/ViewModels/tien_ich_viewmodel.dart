import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/Services/tien_ich_service.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';

class TienIchViewModel extends ChangeNotifier {
  final TienIchService _service;
  final CanHoService _canHoService;

  TienIchViewModel({
    TienIchService? service,
    CanHoService? canHoService,
  })  : _service = service ?? TienIchService(),
        _canHoService = canHoService ?? CanHoService();

  bool isLoading = false;
  String? error;
  List<TienIch> items = [];
  String searchQuery = '';

  // Dropdown list data for forms
  List<Map<String, dynamic>> loaiTienIchs = [];
  List<Map<String, dynamic>> toaNhas = [];

  List<TienIch> get filteredItems {
    if (searchQuery.trim().isEmpty) {
      return items;
    }
    return items
        .where((item) =>
            item.tenTienIch.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchTienIchs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      items = await _service.fetchTienIchs();
      error = null;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFormDropdowns() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchLoaiTienIchs(),
        _canHoService.fetchToaNhas(),
      ]);

      loaiTienIchs = results[0];
      toaNhas = results[1];
      error = null;
    } catch (e) {
      error = 'Không thể tải dữ liệu danh mục phụ';
      debugPrint('Error loading form dropdowns: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final created = await _service.createTienIch(data);
      items.insert(0, created);
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

  Future<bool> update(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updateTienIch(id, data);
      if (success) {
        final index = items.indexWhere((element) => element.id == id);
        if (index != -1) {
          final updatedItem = await _service.getById(id);
          items[index] = updatedItem;
        }
        error = null;
        return true;
      }
      error = 'Cập nhật tiện ích thất bại';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deleteTienIch(id);
      if (success) {
        items.removeWhere((element) => element.id == id);
        error = null;
        return true;
      }
      error = 'Xóa tiện ích thất bại';
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
