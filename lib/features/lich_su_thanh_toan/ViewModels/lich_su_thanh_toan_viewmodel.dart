import 'package:flutter/material.dart';
import 'package:urbano_manage/Models/lich_su_thanh_toan_model.dart';
import 'package:urbano_manage/Services/lich_su_thanh_toan_service.dart';

class LichSuThanhToanViewModel extends ChangeNotifier {
  final LichSuThanhToanService _service;

  LichSuThanhToanViewModel({LichSuThanhToanService? service}) : _service = service ?? LichSuThanhToanService();

  List<LichSuThanhToan> _histories = [];
  List<LichSuThanhToan> get histories => _histories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchHistories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _histories = await _service.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
