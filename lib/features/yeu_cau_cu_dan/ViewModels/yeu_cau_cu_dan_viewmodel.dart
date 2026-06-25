import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';
import 'package:urbano_manage/Services/yeu_cau_cu_dan_service.dart';

class YeuCauCuDanViewModel extends ChangeNotifier {
  final YeuCauCuDanService _service = YeuCauCuDanService();

  bool isLoading = false;
  String? error;
  List<YeuCauCuDan> yeuCaus = [];
  int currentTab = 0; // 0: Tất cả, 1: Chờ xử lý, 2: Đang xử lý, 3: Đã xong (Hoàn thành / Từ chối)

  Future<void> fetchRequests() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      int? statusQuery;
      // Map currentTab to database TrangThai:
      // Tab 0: Tất cả (null)
      // Tab 1: Chờ xử lý (1)
      // Tab 2: Đang xử lý (2)
      // Tab 3: Đã hoàn thành (3) hoặc Từ chối (4)
      if (currentTab == 1) {
        statusQuery = 1;
      } else if (currentTab == 2) {
        statusQuery = 2;
      }

      final fetched = await _service.fetchYeuCaus(trangThai: statusQuery);
      
      if (currentTab == 3) {
        yeuCaus = fetched.where((y) => y.trangThai == 3 || y.trangThai == 4).toList();
      } else if (currentTab == 0) {
        yeuCaus = fetched;
      } else {
        yeuCaus = fetched;
      }
      
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách yêu cầu. Vui lòng thử lại.';
      yeuCaus = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeTab(int tabIndex) {
    currentTab = tabIndex;
    fetchRequests();
  }

  Future<bool> updateRequestStatus(int id, int trangThai, int? nhanVienId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.updateStatus(id, trangThai, nhanVienId);
      if (success) {
        await fetchRequests(); // Refresh the list
        return true;
      } else {
        error = 'Cập nhật trạng thái thất bại';
        return false;
      }
    } catch (e) {
      error = 'Đã xảy ra lỗi khi cập nhật trạng thái';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
