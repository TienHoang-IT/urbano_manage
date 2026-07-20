import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/phuong_tien_model.dart';
import 'package:urbano_manage/features/phuong_tien/ViewModels/phuong_tien_viewmodel.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/core/Widgets/app_searchable_picker.dart';

class PhuongTienFormView extends StatefulWidget {
  final PhuongTien? phuongTien;

  const PhuongTienFormView({super.key, this.phuongTien});

  @override
  State<PhuongTienFormView> createState() => _PhuongTienFormViewState();
}

class _PhuongTienFormViewState extends State<PhuongTienFormView> {
  final _tenController = TextEditingController();
  final _bienSoController = TextEditingController();

  int? _selectedLoaiId;
  int? _selectedCanHoId;
  int _selectedTrangThai = 1; // 1: Đang hoạt động, 2: Đã hủy

  int _loggedInStaffId = 1;

  @override
  void initState() {
    super.initState();
    _loadLoggedInStaffId();

    final pvm = context.read<PhuongTienViewModel>();
    final cvm = context.read<CanHoViewModel>();

    Future.wait([
      pvm.fetchLookups(),
      cvm.fetchCanHos(),
    ]).then((_) {
      if (widget.phuongTien == null && mounted) {
        setState(() {
          if (pvm.vehicleTypes.isNotEmpty) _selectedLoaiId = pvm.vehicleTypes.first.id;
          if (cvm.canHos.isNotEmpty) _selectedCanHoId = cvm.canHos.first.id;
        });
      }
    });

    if (widget.phuongTien != null) {
      final pt = widget.phuongTien!;
      _tenController.text = pt.tenPhuongTien;
      _bienSoController.text = pt.bienSo;
      _selectedLoaiId = pt.loaiPhuongTienId;
      _selectedCanHoId = pt.canHoId;
      _selectedTrangThai = pt.trangThai;
    }
  }

  Future<void> _loadLoggedInStaffId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nvStr = prefs.getString('nhanVien');
      if (nvStr != null) {
        final nvMap = jsonDecode(nvStr) as Map<String, dynamic>;
        setState(() {
          _loggedInStaffId = nvMap['id'] as int? ?? 1;
        });
      }
    } catch (e) {
      debugPrint('Error loading staff ID: $e');
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _bienSoController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final name = _tenController.text.trim();
    final plate = _bienSoController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên phương tiện')));
      return;
    }
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập biển số xe')));
      return;
    }
    if (_selectedLoaiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn loại xe')));
      return;
    }
    if (_selectedCanHoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn căn hộ sở hữu')));
      return;
    }

    final data = {
      'tenPhuongTien': name,
      'bienSo': plate,
      'loaiPhuongTienId': _selectedLoaiId,
      'canHoId': _selectedCanHoId,
      'trangThai': _selectedTrangThai,
      'nguoiCapNhatId': _loggedInStaffId,
      'ngayDangKy': widget.phuongTien?.ngayDangKy?.toIso8601String() ?? DateTime.now().toIso8601String(),
      if (_selectedTrangThai == 2) 'ngayHuy': DateTime.now().toIso8601String(),
    };

    final viewModel = context.read<PhuongTienViewModel>();
    bool success;
    if (widget.phuongTien != null) {
      success = await viewModel.editItem(widget.phuongTien!.id, data);
    } else {
      success = await viewModel.addItem(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.phuongTien != null ? 'Cập nhật phương tiện thành công' : 'Thêm phương tiện thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Đã xảy ra lỗi'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pvm = context.watch<PhuongTienViewModel>();
    final cvm = context.watch<CanHoViewModel>();
    final isEdit = widget.phuongTien != null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppbar(context, isEdit),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'TÊN PHƯƠNG TIỆN *',
                        hint: 'Ví dụ: Wave Alpha, Honda City',
                        controller: _tenController,
                        prefixIcon: Icons.motorcycle_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'BIỂN SỐ XE *',
                        hint: 'Ví dụ: 29-A1 12345',
                        controller: _bienSoController,
                        prefixIcon: Icons.tag_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'LOẠI XE *',
                        value: _selectedLoaiId,
                        hint: 'Chọn loại phương tiện',
                        prefixIcon: Icons.category_rounded,
                        onChanged: (val) => setState(() => _selectedLoaiId = val),
                        items: pvm.vehicleTypes
                            .map((e) => DropdownMenuItem<int>(
                                  value: e.id,
                                  child: Text(e.tenLoaiPhuongTien),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      AppSearchablePicker<CanHo>(
                        label: 'CĂN HỘ SỞ HỮU *',
                        value: cvm.canHos.where((c) => c.id == _selectedCanHoId).firstOrNull,
                        hint: 'Chọn căn hộ',
                        prefixIcon: Icons.apartment_rounded,
                        items: cvm.canHos,
                        isLoading: cvm.isLoading,
                        itemAsString: (c) => 'Căn hộ ${c.soCanHo} (${c.tenToaNha})',
                        searchFn: (c, query) {
                          return c.soCanHo.toLowerCase().contains(query) ||
                              c.tenToaNha.toLowerCase().contains(query);
                        },
                        onChanged: (val) => setState(() => _selectedCanHoId = val.id),
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'TRẠNG THÁI *',
                        value: _selectedTrangThai,
                        hint: 'Chọn trạng thái',
                        prefixIcon: Icons.info_outline_rounded,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTrangThai = val);
                        },
                        items: const [
                          DropdownMenuItem<int>(value: 1, child: Text('Đang hoạt động')),
                          DropdownMenuItem<int>(value: 2, child: Text('Đã hủy')),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: pvm.isLoading || cvm.isLoading
                            ? 'Đang tải dữ liệu...'
                            : (isEdit ? 'Cập Nhật' : 'Thêm Mới'),
                        onPressed: pvm.isLoading || cvm.isLoading ? null : _saveForm,
                        isLoading: pvm.isLoading,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context, bool isEdit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit ? 'Sửa thông tin Phương tiện' : 'Thêm Phương tiện mới',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
