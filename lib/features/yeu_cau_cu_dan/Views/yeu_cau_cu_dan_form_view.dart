import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/ViewModels/yeu_cau_cu_dan_viewmodel.dart';

class YeuCauCuDanFormView extends StatefulWidget {
  const YeuCauCuDanFormView({super.key});

  @override
  State<YeuCauCuDanFormView> createState() => _YeuCauCuDanFormViewState();
}

class _FormInputs {
  int? selectedCuDanId;
  int? selectedLoaiYeuCauId;
  int selectedPriority = 2; // Default to Middle/Trung bình
  int? selectedStaffId;
}

class _YeuCauCuDanFormViewState extends State<YeuCauCuDanFormView> {
  final _tieuDeController = TextEditingController();
  final _noiDungController = TextEditingController();

  final _inputs = _FormInputs();
  int _loggedInStaffId = 1;

  @override
  void initState() {
    super.initState();
    _loadLoggedInStaffId();

    final vm = context.read<YeuCauCuDanViewModel>();
    if (vm.cuDans.isNotEmpty) {
      _inputs.selectedCuDanId = vm.cuDans.first.id;
    }
    if (vm.loaiYeuCaus.isNotEmpty) {
      _inputs.selectedLoaiYeuCauId = vm.loaiYeuCaus.first.id;
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
    _tieuDeController.dispose();
    _noiDungController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final title = _tieuDeController.text.trim();
    final content = _noiDungController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tiêu đề yêu cầu')));
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung chi tiết')));
      return;
    }
    if (_inputs.selectedCuDanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn cư dân phản ánh')));
      return;
    }
    if (_inputs.selectedLoaiYeuCauId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn loại yêu cầu')));
      return;
    }

    final data = {
      'cuDan': _inputs.selectedCuDanId,
      'loaiYeuCau': _inputs.selectedLoaiYeuCauId,
      'tieuDe': title,
      'noiDung': content,
      'mucDoUuTien': _inputs.selectedPriority,
      'trangThai': 1, // Default to 1 (Chờ xử lý)
      'nhanVienXuLy': _inputs.selectedStaffId,
      'nguoiCapNhat': _loggedInStaffId,
    };

    final viewModel = context.read<YeuCauCuDanViewModel>();
    final success = await viewModel.addYeuCau(data);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo yêu cầu cư dân thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Đã xảy ra lỗi khi tạo yêu cầu'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<YeuCauCuDanViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
              _buildAppbar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppDropdownField<int>(
                        label: 'CƯ DÂN PHẢN ÁNH *',
                        value: _inputs.selectedCuDanId,
                        hint: 'Chọn cư dân phản ánh',
                        prefixIcon: Icons.person_rounded,
                        onChanged: (val) => setState(() => _inputs.selectedCuDanId = val),
                        items: viewModel.cuDans
                            .map((c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text('${c.hoTenDem} ${c.ten} (${c.sdt})'),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'LOẠI YÊU CẦU *',
                        value: _inputs.selectedLoaiYeuCauId,
                        hint: 'Chọn phân loại yêu cầu',
                        prefixIcon: Icons.category_rounded,
                        onChanged: (val) => setState(() => _inputs.selectedLoaiYeuCauId = val),
                        items: viewModel.loaiYeuCaus
                            .map((l) => DropdownMenuItem<int>(
                                  value: l.id,
                                  child: Text(l.name),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'TIÊU ĐỀ YÊU CẦU *',
                        hint: 'Ví dụ: Hỏng bóng đèn hành lang, Rò rỉ nước',
                        controller: _tieuDeController,
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'NỘI DUNG CHI TIẾT *',
                        hint: 'Mô tả chi tiết sự cố hoặc phản ánh...',
                        controller: _noiDungController,
                        prefixIcon: Icons.description_rounded,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'MỨC ĐỘ ƯU TIÊN *',
                        value: _inputs.selectedPriority,
                        hint: 'Chọn độ ưu tiên',
                        prefixIcon: Icons.priority_high_rounded,
                        onChanged: (val) {
                          if (val != null) setState(() => _inputs.selectedPriority = val);
                        },
                        items: const [
                          DropdownMenuItem<int>(value: 1, child: Text('Thấp')),
                          DropdownMenuItem<int>(value: 2, child: Text('Trung bình')),
                          DropdownMenuItem<int>(value: 3, child: Text('Cao')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'NHÂN VIÊN XỬ LÝ (TÙY CHỌN)',
                        value: _inputs.selectedStaffId,
                        hint: 'Chọn nhân viên phụ trách',
                        prefixIcon: Icons.badge_rounded,
                        onChanged: (val) => setState(() => _inputs.selectedStaffId = val),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Chưa phân công (BQL)'),
                          ),
                          ...viewModel.nhanViens.map((nv) => DropdownMenuItem<int>(
                                value: nv.id,
                                child: Text('${nv.hoTen} (${nv.maNhanVien})'),
                              )),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: viewModel.isLoading ? 'Đang tạo...' : 'Tạo Yêu Cầu',
                        onPressed: viewModel.isLoading ? null : _submitForm,
                        isLoading: viewModel.isLoading,
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

  Widget _buildAppbar(BuildContext context) {
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Tạo yêu cầu mới',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
