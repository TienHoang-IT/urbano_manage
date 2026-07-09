import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';

class CuDanViewModel extends ChangeNotifier {
  final CuDanService _service;

  CuDanViewModel({CuDanService? service}) : _service = service ?? CuDanService();

  List<CuDan> cuDans = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchCuDans() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      cuDans = await _service.fetchCuDans();
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách cư dân';
      cuDans = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCuDan(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.createCuDan(data);
      await fetchCuDans(); // refresh list
      return true;
    } catch (e) {
      error = 'Không thể tạo cư dân mới';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editCuDan(int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updateCuDan(id, data);
      if (success) {
        await fetchCuDans(); // refresh list
        return true;
      } else {
        error = 'Cập nhật cư dân thất bại';
        return false;
      }
    } catch (e) {
      error = 'Lỗi xảy ra khi cập nhật cư dân';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeCuDan(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deleteCuDan(id);
      if (success) {
        await fetchCuDans(); // refresh list
        return true;
      } else {
        error = 'Xóa cư dân thất bại';
        return false;
      }
    } catch (e) {
      error = 'Lỗi xảy ra khi xóa cư dân';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCuDan(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.verifyCuDan(id);
      if (success) {
        await fetchCuDans(); // refresh list
        return true;
      } else {
        error = 'Xác thực cư dân thất bại';
        return false;
      }
    } catch (e) {
      error = 'Lỗi xảy ra khi xác thực cư dân';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
