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
}
