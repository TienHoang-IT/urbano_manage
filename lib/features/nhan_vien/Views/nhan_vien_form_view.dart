import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/core/Widgets/app_date_picker.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';
import 'package:urbano_manage/features/nhan_vien/ViewModels/nhan_vien_viewmodel.dart';

class NhanVienFormView extends StatefulWidget {
  final NhanVien? nhanVien;

  const NhanVienFormView({super.key, this.nhanVien});

  @override
  State<NhanVienFormView> createState() => _NhanVienFormViewState();
}

class _NhanVienFormViewState extends State<NhanVienFormView> {
  final _hoTenController = TextEditingController();
  final _maNhanVienController = TextEditingController();
  final _sdtController = TextEditingController();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _cccdController = TextEditingController();
  final _ghiChuController = TextEditingController();

  int _selectedChucVu = 3; // Default to Technical (3)
  DateTime? _selectedDob;
  int _selectedTrangThai = 1; // 1: Đang làm việc, 0: Đã nghỉ việc

  @override
  void initState() {
    super.initState();
    if (widget.nhanVien != null) {
      final nv = widget.nhanVien!;
      _hoTenController.text = nv.hoTen;
      _maNhanVienController.text = nv.maNhanVien;
      _sdtController.text = nv.sdt;
      _emailController.text = nv.email;
      _cccdController.text = nv.cccd;
      _ghiChuController.text = nv.ghiChu;
      _selectedChucVu = nv.chucVu;
      _selectedTrangThai = nv.trangThai;
      _selectedDob = nv.ngaySinh;
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _maNhanVienController.dispose();
    _sdtController.dispose();
    _emailController.dispose();
    _matKhauController.dispose();
    _cccdController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final hoTen = _hoTenController.text.trim();
    final maNv = _maNhanVienController.text.trim();

    if (hoTen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Họ tên nhân viên')),
      );
      return;
    }
    if (maNv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Mã nhân viên')),
      );
      return;
    }
    if (widget.nhanVien == null && _matKhauController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Mật khẩu cho nhân viên mới')),
      );
      return;
    }

    final data = {
      'hoTen': hoTen,
      'maNhanVien': maNv,
      'chucVu': _selectedChucVu,
      'sdt': _sdtController.text.trim(),
      'email': _emailController.text.trim(),
      'cccd': _cccdController.text.trim(),
      'ghiChu': _ghiChuController.text.trim(),
      'trangThai': _selectedTrangThai,
      'ngaySinh': _selectedDob?.toIso8601String(),
    };

    // If password is typed, include it (or if it's new user, it's mandatory)
    if (_matKhauController.text.trim().isNotEmpty) {
      data['matKhau'] = _matKhauController.text.trim();
    } else if (widget.nhanVien != null) {
      // In edit mode, if password is empty, don't change it on server
      data['matKhau'] = '';
    }

    final viewModel = context.read<NhanVienViewModel>();
    bool success;
    if (widget.nhanVien != null) {
      success = await viewModel.editNhanVien(widget.nhanVien!.id, data);
    } else {
      // For creation, add date fields
      data['ngayVaoLam'] = DateTime.now().toIso8601String();
      success = await viewModel.addNhanVien(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.nhanVien != null ? 'Cập nhật nhân viên thành công' : 'Thêm nhân viên thành công'),
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
    final viewModel = context.watch<NhanVienViewModel>();
    final isEdit = widget.nhanVien != null;

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
                        label: 'HỌ VÀ TÊN *',
                        hint: 'Nhập họ và tên nhân viên',
                        controller: _hoTenController,
                        prefixIcon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'MÃ NHÂN VIÊN *',
                        hint: 'Nhập mã nhân viên (ví dụ: NV001)',
                        controller: _maNhanVienController,
                        prefixIcon: Icons.badge_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'CHỨC VỤ',
                        value: _selectedChucVu,
                        hint: 'Chọn chức vụ',
                        prefixIcon: Icons.work_rounded,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedChucVu = val);
                        },
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Admin')),
                          DropdownMenuItem(value: 2, child: Text('Kế toán')),
                          DropdownMenuItem(value: 3, child: Text('Kỹ thuật')),
                          DropdownMenuItem(value: 4, child: Text('Lễ tân')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppDatePicker(
                        label: 'NGÀY SINH',
                        hint: 'Chọn ngày sinh',
                        selectedDate: _selectedDob,
                        onDateSelected: (date) {
                          setState(() => _selectedDob = date);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'SỐ ĐIỆN THOẠI',
                        hint: 'Nhập số điện thoại',
                        controller: _sdtController,
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'EMAIL',
                        hint: 'Nhập địa chỉ email',
                        controller: _emailController,
                        prefixIcon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: isEdit ? 'MẬT KHẨU (BỎ TRỐNG NẾU GIỮ NGUYÊN)' : 'MẬT KHẨU *',
                        hint: 'Nhập mật khẩu đăng nhập',
                        controller: _matKhauController,
                        prefixIcon: Icons.lock_rounded,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'SỐ CCCD',
                        hint: 'Nhập số căn cước công dân',
                        controller: _cccdController,
                        prefixIcon: Icons.perm_identity_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      if (isEdit) ...[
                        AppDropdownField<int>(
                          label: 'TRẠNG THÁI',
                          value: _selectedTrangThai,
                          hint: 'Chọn trạng thái',
                          prefixIcon: Icons.toggle_on_rounded,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedTrangThai = val);
                          },
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Đang làm việc')),
                            DropdownMenuItem(value: 0, child: Text('Đã nghỉ việc')),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        label: 'GHI CHÚ',
                        hint: 'Nhập ghi chú (nếu có)',
                        controller: _ghiChuController,
                        prefixIcon: Icons.notes_rounded,
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
              isEdit ? 'Sửa thông tin Nhân viên' : 'Thêm Nhân viên mới',
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
