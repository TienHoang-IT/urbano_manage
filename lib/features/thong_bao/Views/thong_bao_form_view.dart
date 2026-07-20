import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/Models/thong_bao_model.dart';
import 'package:urbano_manage/features/thong_bao/ViewModels/thong_bao_viewmodel.dart';

class ThongBaoFormView extends StatefulWidget {
  final ThongBao? thongBao;

  const ThongBaoFormView({super.key, this.thongBao});

  @override
  State<ThongBaoFormView> createState() => _ThongBaoFormViewState();
}

class _ThongBaoFormViewState extends State<ThongBaoFormView> {
  final _tieuDeController = TextEditingController();
  final _noiDungController = TextEditingController();

  int? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
    if (widget.thongBao != null) {
      _tieuDeController.text = widget.thongBao!.tieuDe;
      _noiDungController.text = widget.thongBao!.noiDung;
    }
  }

  @override
  void dispose() {
    _tieuDeController.dispose();
    _noiDungController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nvStr = prefs.getString('nhanVien');
      if (nvStr != null) {
        final nvMap = jsonDecode(nvStr) as Map<String, dynamic>;
        setState(() {
          _employeeId = nvMap['id'] as int?;
        });
      }
    } catch (e) {
      debugPrint('Error loading employee ID in ThongBaoForm: $e');
    }
  }

  Future<void> _saveForm() async {
    final tieuDe = _tieuDeController.text.trim();
    final noiDung = _noiDungController.text.trim();

    if (tieuDe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tiêu đề thông báo')));
      return;
    }
    if (noiDung.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung thông báo')));
      return;
    }

    final data = {
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'nguoiTao': _employeeId ?? 1,
    };

    final viewModel = context.read<ThongBaoViewModel>();
    bool success;
    if (widget.thongBao != null) {
      success = await viewModel.editThongBao(widget.thongBao!.id, data);
    } else {
      success = await viewModel.addThongBao(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.thongBao != null ? 'Cập nhật thông báo thành công' : 'Đăng thông báo thành công'),
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
    final viewModel = context.watch<ThongBaoViewModel>();
    final isEdit = widget.thongBao != null;

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
                        label: 'TIÊU ĐỀ *',
                        hint: 'Nhập tiêu đề thông báo',
                        controller: _tieuDeController,
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'NỘI DUNG *',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noiDungController,
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Nhập nội dung chi tiết thông báo...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.all(14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderSide, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.tealPrimary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: viewModel.isLoading ? 'Đang xử lý...' : (isEdit ? 'Cập Nhật' : 'Đăng Thông Báo'),
                        onPressed: viewModel.isLoading ? null : _saveForm,
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
              isEdit ? 'Chỉnh sửa Thông báo' : 'Tạo Thông báo mới',
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
