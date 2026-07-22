import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/features/cu_dan/ViewModels/cu_dan_viewmodel.dart';
import 'package:urbano_manage/core/utils/app_validators.dart';
import 'package:urbano_manage/Services/province_service.dart';

class CuDanFormView extends StatefulWidget {
  final CuDan? cuDan;

  const CuDanFormView({super.key, this.cuDan});

  @override
  State<CuDanFormView> createState() => _CuDanFormViewState();
}

class _CuDanFormViewState extends State<CuDanFormView> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenDemController = TextEditingController();
  final _tenController = TextEditingController();
  final _sdtController = TextEditingController();
  final _cccdController = TextEditingController();
  final _emailController = TextEditingController();
  final _ngaySinhController = TextEditingController();
  final _tinhController = TextEditingController();
  final _xaController = TextEditingController();
  final _diaChiController = TextEditingController();

  DateTime? _selectedDob;
  int _selectedGender = 0; // 0: Nam, 1: Nữ, 2: Khác
  int _selectedStatus = 2; // Mặc định 2: Đang cư trú (Đã xác thực) khi thêm cư dân mới

  final ProvinceService _provinceService = ProvinceService();
  List<Province> _provinces = [];
  List<Ward> _wards = [];
  int? _selectedProvinceCode;
  int? _selectedWardCode;
  bool _isLoadingProvinces = false;
  bool _isLoadingWards = false;

  @override
  void initState() {
    super.initState();
    if (widget.cuDan != null) {
      final c = widget.cuDan!;
      _hoTenDemController.text = c.hoTenDem;
      _tenController.text = c.ten;
      _sdtController.text = c.sdt;
      _cccdController.text = c.cccd;
      _emailController.text = c.email;
      _tinhController.text = c.tinh;
      _xaController.text = c.xa;
      _diaChiController.text = c.diaChi;
      _selectedGender = c.gioiTinh ?? 0;
      _selectedStatus = [1, 2, 3].contains(c.trangThai) ? c.trangThai : 2;
      if (c.ngaySinh != null) {
        _selectedDob = c.ngaySinh;
        _ngaySinhController.text = DateFormat('dd/MM/yyyy').format(c.ngaySinh!.toLocal());
      }
    }
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    setState(() => _isLoadingProvinces = true);
    try {
      final provincesList = await _provinceService.fetchProvinces();
      if (!mounted) return;
      setState(() {
        _provinces = provincesList;
        _isLoadingProvinces = false;
      });

      if (_tinhController.text.isNotEmpty) {
        final currentTinhText = _tinhController.text.trim().toLowerCase();
        final matchedProvince = _provinces.firstWhere(
          (p) => p.name.toLowerCase() == currentTinhText || currentTinhText.contains(p.name.toLowerCase()),
          orElse: () => Province(code: 0, name: '', codename: '', divisionType: ''),
        );

        if (matchedProvince.code != 0) {
          setState(() {
            _selectedProvinceCode = matchedProvince.code;
          });
          await _onProvinceChanged(matchedProvince.code, isInitial: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProvinces = false);
      }
    }
  }

  Future<void> _onProvinceChanged(int? provinceCode, {bool isInitial = false}) async {
    if (provinceCode == null) return;
    final selectedProv = _provinces.firstWhere(
      (p) => p.code == provinceCode,
      orElse: () => Province(code: provinceCode, name: _tinhController.text, codename: '', divisionType: ''),
    );

    setState(() {
      _selectedProvinceCode = provinceCode;
      if (!isInitial || _tinhController.text.isEmpty) {
        _tinhController.text = selectedProv.name;
      }
      _selectedWardCode = null;
      if (!isInitial) {
        _xaController.text = '';
      }
      _wards = [];
      _isLoadingWards = true;
    });

    try {
      final wardsList = await _provinceService.fetchWards(provinceCode);
      if (!mounted) return;
      setState(() {
        _wards = wardsList;
        _isLoadingWards = false;
      });

      if (isInitial && _xaController.text.isNotEmpty) {
        final currentXaText = _xaController.text.trim().toLowerCase();
        final matchedWard = _wards.firstWhere(
          (w) => w.name.toLowerCase() == currentXaText || currentXaText.contains(w.name.toLowerCase()),
          orElse: () => Ward(code: 0, name: '', codename: '', divisionType: '', provinceCode: 0),
        );
        if (matchedWard.code != 0) {
          setState(() {
            _selectedWardCode = matchedWard.code;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWards = false);
      }
    }
  }

  @override
  void dispose() {
    _hoTenDemController.dispose();
    _tenController.dispose();
    _sdtController.dispose();
    _cccdController.dispose();
    _emailController.dispose();
    _ngaySinhController.dispose();
    _tinhController.dispose();
    _xaController.dispose();
    _diaChiController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.tealPrimary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.bgDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _ngaySinhController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra và điền đúng thông tin theo yêu cầu')),
      );
      return;
    }

    final hoTenDem = _hoTenDemController.text.trim();
    final ten = _tenController.text.trim();

    final data = {
      'hoTenDem': hoTenDem,
      'ten': ten,
      'sdt': _sdtController.text.trim(),
      'cccd': _cccdController.text.trim(),
      'email': _emailController.text.trim(),
      'ngaySinh': _selectedDob?.toIso8601String(),
      'gioiTinh': _selectedGender,
      'tinh': _tinhController.text.trim(),
      'xa': _xaController.text.trim(),
      'diaChi': _diaChiController.text.trim(),
      'trangThai': _selectedStatus,
    };

    final viewModel = context.read<CuDanViewModel>();
    bool success;
    if (widget.cuDan != null) {
      success = await viewModel.editCuDan(widget.cuDan!.id, data);
    } else {
      success = await viewModel.addCuDan(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cuDan != null ? 'Cập nhật cư dân thành công' : 'Thêm cư dân thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true); // Return true to refresh
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
    final viewModel = context.watch<CuDanViewModel>();
    final isEdit = widget.cuDan != null;

    final validProvinceCode = _provinces.any((p) => p.code == _selectedProvinceCode) ? _selectedProvinceCode : null;
    final validWardCode = _wards.any((w) => w.code == _selectedWardCode) ? _selectedWardCode : null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppbar(context, isEdit),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'HỌ VÀ TÊN ĐỆM *',
                          hint: 'Nhập họ và tên đệm',
                          controller: _hoTenDemController,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) => AppValidators.validateName(v, fieldName: 'Họ và tên đệm'),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'TÊN CƯ DÂN *',
                          hint: 'Nhập tên cư dân',
                          controller: _tenController,
                          prefixIcon: Icons.person_rounded,
                          validator: (v) => AppValidators.validateName(v, fieldName: 'Tên cư dân'),
                        ),
                        const SizedBox(height: 16),
                        AppDropdownField<int>(
                          label: 'GIỚI TÍNH',
                          hint: 'Chọn giới tính',
                          value: _selectedGender,
                          prefixIcon: Icons.wc_rounded,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedGender = val);
                          },
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Nam')),
                            DropdownMenuItem(value: 1, child: Text('Nữ')),
                            DropdownMenuItem(value: 2, child: Text('Khác')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDob(context),
                          child: AbsorbPointer(
                            child: AppTextField(
                              label: 'NGÀY SINH',
                              hint: 'Chọn ngày sinh',
                              controller: _ngaySinhController,
                              prefixIcon: Icons.cake_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'SỐ CCCD',
                          hint: 'Nhập số căn cước công dân',
                          controller: _cccdController,
                          prefixIcon: Icons.badge_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) => AppValidators.validateCccd(v),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'SỐ ĐIỆN THOẠI',
                          hint: 'Nhập số điện thoại',
                          controller: _sdtController,
                          prefixIcon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) => AppValidators.validatePhone(v),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'EMAIL',
                          hint: 'Nhập địa chỉ email',
                          controller: _emailController,
                          prefixIcon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => AppValidators.validateEmail(v),
                        ),
                        const SizedBox(height: 16),
                        AppDropdownField<int>(
                          label: 'TỈNH / THÀNH PHỐ',
                          hint: _isLoadingProvinces ? 'Đang tải danh sách Tỉnh/Thành phố...' : 'Chọn Tỉnh / Thành phố',
                          value: validProvinceCode,
                          prefixIcon: Icons.location_city_rounded,
                          onChanged: (val) => _onProvinceChanged(val),
                          items: _provinces.map((p) {
                            return DropdownMenuItem<int>(
                              value: p.code,
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        AppDropdownField<int>(
                          label: 'PHƯỜNG / XÃ',
                          hint: _selectedProvinceCode == null
                              ? 'Vui lòng chọn Tỉnh/Thành phố trước'
                              : (_isLoadingWards ? 'Đang tải danh sách Phường/Xã...' : 'Chọn Phường / Xã'),
                          value: validWardCode,
                          prefixIcon: Icons.map_rounded,
                          onChanged: (val) {
                            if (val == null) return;
                            final w = _wards.firstWhere(
                              (item) => item.code == val,
                              orElse: () => Ward(code: val, name: '', codename: '', divisionType: '', provinceCode: 0),
                            );
                            setState(() {
                              _selectedWardCode = val;
                              _xaController.text = w.name;
                            });
                          },
                          items: _wards.map((w) {
                            return DropdownMenuItem<int>(
                              value: w.code,
                              child: Text(
                                w.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'ĐỊA CHỈ CHI TIẾT',
                          hint: 'Nhập số nhà, tên đường...',
                          controller: _diaChiController,
                          prefixIcon: Icons.location_on_rounded,
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          label: isEdit ? 'LƯU THAY ĐỔI' : 'TẠO CƯ DÂN MỚI',
                          isLoading: viewModel.isLoading,
                          onPressed: _saveForm,
                        ),
                        if (isEdit) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.borderButton),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: viewModel.isLoading ? null : () => _showChangePasswordDialog(context),
                              child: Text('Đổi mật khẩu tài khoản', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isEdit ? 'Sửa thông tin Cư dân' : 'Thêm Cư dân mới',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgMid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.borderButton),
          ),
          title: Text('Đổi mật khẩu cư dân', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20, letterSpacing: -0.5)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nhập mật khẩu mới cho cư dân này:', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 16),
              AppTextField(
                label: 'MẬT KHẨU MỚI',
                hint: 'Nhập mật khẩu',
                controller: passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              child: Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              child: Text('Xác nhận', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final pwd = passwordController.text.trim();
                if (pwd.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập mật khẩu mới')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(); // close dialog

                final vm = context.read<CuDanViewModel>();
                final success = await vm.adminResetPassword(widget.cuDan!.id, pwd);

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đổi mật khẩu thành công'), backgroundColor: AppColors.tealPrimary),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vm.error ?? 'Đã xảy ra lỗi'), backgroundColor: AppColors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
