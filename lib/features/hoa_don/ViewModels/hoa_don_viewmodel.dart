import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';

class HoaDonViewModel extends ChangeNotifier {
  final HoaDonService _service;

  HoaDonViewModel({HoaDonService? service}) : _service = service ?? HoaDonService();

  List<HoaDon> hoaDons = [];
  bool isLoading = false;
  String? error;
  int currentTab = 0; // 0: Tất cả, 1: Chưa thanh toán, 2: Đã thanh toán, 3: Thanh toán một phần

  Future<void> fetchHoaDons() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final allInvoices = await _service.fetchHoaDons();
      if (currentTab == 0) {
        hoaDons = allInvoices;
      } else {
        hoaDons = allInvoices.where((h) => h.trangThai == currentTab).toList();
      }
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách hóa đơn';
      hoaDons = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeTab(int index) {
    currentTab = index;
    fetchHoaDons();
  }
}
