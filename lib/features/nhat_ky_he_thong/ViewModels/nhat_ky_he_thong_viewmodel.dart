import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/nhat_ky_he_thong_model.dart';
import 'package:urbano_manage/Services/nhat_ky_he_thong_service.dart';

class NhatKyHeThongViewModel extends ChangeNotifier {
  final NhatKyHeThongService _service = NhatKyHeThongService();

  List<NhatKyHeThong> logs = [];
  bool isLoading = false;
  bool isLoadMore = false;
  String? error;

  int pageNumber = 1;
  int pageSize = 15;
  int totalPages = 1;
  int totalRecords = 0;

  // Filters
  String? bangTacDongFilter;
  DateTime? fromFilter;
  DateTime? toFilter;
  String? searchTerm;

  Future<void> fetchLogs({bool refresh = true}) async {
    if (refresh) {
      pageNumber = 1;
      isLoading = true;
      error = null;
      logs.clear();
      notifyListeners();
    } else {
      if (pageNumber >= totalPages) return; // No more pages
      pageNumber++;
      isLoadMore = true;
      notifyListeners();
    }

    try {
      final paged = await _service.fetchLogs(
        bangTacDong: bangTacDongFilter,
        from: fromFilter,
        to: toFilter,
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
      );

      if (refresh) {
        logs = paged.items;
      } else {
        logs.addAll(paged.items);
      }

      totalPages = paged.totalPages;
      totalRecords = paged.totalRecords;
      error = null;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      if (!refresh && pageNumber > 1) {
        pageNumber--; // Rollback page number
      }
    } finally {
      isLoading = false;
      isLoadMore = false;
      notifyListeners();
    }
  }

  void updateFilters({
    String? bangTacDong,
    DateTime? from,
    DateTime? to,
    String? search,
  }) {
    bangTacDongFilter = bangTacDong;
    fromFilter = from;
    toFilter = to;
    searchTerm = search;
    fetchLogs(refresh: true);
  }

  void clearFilters() {
    bangTacDongFilter = null;
    fromFilter = null;
    toFilter = null;
    searchTerm = null;
    fetchLogs(refresh: true);
  }
}
