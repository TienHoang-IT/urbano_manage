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
}
