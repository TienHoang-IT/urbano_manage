import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';
import 'package:urbano_manage/Services/yeu_cau_cu_dan_service.dart';

class YeuCauCuDanViewModel extends ChangeNotifier {
  final YeuCauCuDanService _service;

  YeuCauCuDanViewModel({
    YeuCauCuDanService? service,
  })  : _service = service ?? YeuCauCuDanService();

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
      if (currentTab == 1) {
        statusQuery = 1;
      } else if (currentTab == 2) {
        statusQuery = 2;
      }

      final fetched = await _service.fetchYeuCaus(trangThai: statusQuery);
      
      if (currentTab == 3) {
        yeuCaus = fetched.where((y) => y.trangThai == 3 || y.trangThai == 4).toList();
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



  /// Deletes a resident request
  Future<bool> removeYeuCau(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _service.deleteYeuCau(id);
      if (success) {
        yeuCaus.removeWhere((item) => item.id == id);
        error = null;
        return true;
      }
      error = 'Không thể xóa yêu cầu';
      return false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
