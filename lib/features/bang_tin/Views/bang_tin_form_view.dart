import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/Models/bang_tin_model.dart';
import 'package:urbano_manage/features/bang_tin/ViewModels/bang_tin_viewmodel.dart';

class BangTinFormView extends StatefulWidget {
  final BangTin? bangTin;

  const BangTinFormView({super.key, this.bangTin});

  @override
  State<BangTinFormView> createState() => _BangTinFormViewState();
}

class _BangTinFormViewState extends State<BangTinFormView> {
  final _tieuDeController = TextEditingController();
  final _noiDungController = TextEditingController();
  final _hinhUrlController = TextEditingController();

  int _loggedInStaffId = 1;

  @override
  void initState() {
    super.initState();
    _loadLoggedInStaffId();

    if (widget.bangTin != null) {
      final b = widget.bangTin!;
      _tieuDeController.text = b.tieuDe;
      _noiDungController.text = b.noiDung;
      _hinhUrlController.text = b.hinhUrl;
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
    _hinhUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final title = _tieuDeController.text.trim();
    final content = _noiDungController.text.trim();
    final imgUrl = _hinhUrlController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tiêu đề')));
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung')));
      return;
    }

    final data = {
      'tieuDe': title,
      'noiDung': content,
      'hinhUrl': imgUrl,
      'nguoiTaoId': widget.bangTin?.nguoiTaoId ?? _loggedInStaffId,
      'nguoiCapNhatId': _loggedInStaffId,
    };

    final viewModel = context.read<BangTinViewModel>();
    bool success;
    if (widget.bangTin != null) {
      success = await viewModel.editItem(widget.bangTin!.id, data);
    } else {
      success = await viewModel.addItem(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.bangTin != null ? 'Cập nhật bảng tin thành công' : 'Thêm bảng tin thành công'),
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
    final viewModel = context.watch<BangTinViewModel>();
    final isEdit = widget.bangTin != null;

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
                        hint: 'Nhập tiêu đề tin tức',
                        controller: _tieuDeController,
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'NỘI DUNG CHI TIẾT *',
                        hint: 'Nhập nội dung bài viết',
                        controller: _noiDungController,
                        prefixIcon: Icons.article_rounded,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'ĐƯỜNG DẪN HÌNH ẢNH (URL)',
                        hint: 'https://example.com/image.png',
                        controller: _hinhUrlController,
                        prefixIcon: Icons.image_rounded,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: viewModel.isLoading ? 'Đang xử lý...' : (isEdit ? 'Cập Nhật' : 'Thêm Mới'),
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
              isEdit ? 'Sửa bài Bảng tin' : 'Thêm tin mới',
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
