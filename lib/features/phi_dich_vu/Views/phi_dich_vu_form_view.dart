import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/phi_dich_vu_model.dart';
import 'package:urbano_manage/features/phi_dich_vu/ViewModels/phi_dich_vu_viewmodel.dart';

class PhiDichVuFormView extends StatefulWidget {
  final PhiDichVu? phiDichVu;

  const PhiDichVuFormView({super.key, this.phiDichVu});

  @override
  State<PhiDichVuFormView> createState() => _PhiDichVuFormViewState();
}

class _PhiDichVuFormViewState extends State<PhiDichVuFormView> {
  final _tenPhiDichVuController = TextEditingController();
  final _donGiaController = TextEditingController();

  int? _selectedLoaiPhiId;
  int? _selectedDonViTinhId;
  int? _selectedLoaiTinhPhiId;

  @override
  void initState() {
    super.initState();
    final vm = context.read<PhiDichVuViewModel>();
    vm.fetchLookups().then((_) {
      if (widget.phiDichVu == null && mounted) {
        setState(() {
          if (vm.feeTypes.isNotEmpty) _selectedLoaiPhiId = vm.feeTypes.first['id'];
          if (vm.unitTypes.isNotEmpty) _selectedDonViTinhId = vm.unitTypes.first['id'];
          if (vm.calcTypes.isNotEmpty) _selectedLoaiTinhPhiId = vm.calcTypes.first['id'];
        });
      }
    });

    if (widget.phiDichVu != null) {
      final p = widget.phiDichVu!;
      _tenPhiDichVuController.text = p.tenPhiDichVu;
      _donGiaController.text = p.donGia.toInt().toString();
      _selectedLoaiPhiId = p.loaiPhiDichVuId;
      _selectedDonViTinhId = p.donViTinhId;
      _selectedLoaiTinhPhiId = p.loaiTinhPhiId;
    }
  }

  @override
  void dispose() {
    _tenPhiDichVuController.dispose();
    _donGiaController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final name = _tenPhiDichVuController.text.trim();
    final price = double.tryParse(_donGiaController.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên phí dịch vụ')));
      return;
    }
    if (_selectedLoaiPhiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn loại phí dịch vụ')));
      return;
    }
    if (price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đơn giá không hợp lệ')));
      return;
    }
    if (_selectedDonViTinhId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn đơn vị tính')));
      return;
    }
    if (_selectedLoaiTinhPhiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn cách tính phí')));
      return;
    }

    final data = {
      'loaiPhiDichVuId': _selectedLoaiPhiId,
      'tenPhiDichVu': name,
      'donGia': price,
      'donViTinhId': _selectedDonViTinhId,
      'loaiTinhPhiId': _selectedLoaiTinhPhiId,
    };

    final viewModel = context.read<PhiDichVuViewModel>();
    bool success;
    if (widget.phiDichVu != null) {
      success = await viewModel.editPhiDichVu(widget.phiDichVu!.id, data);
    } else {
      success = await viewModel.addPhiDichVu(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.phiDichVu != null ? 'Cập nhật phí dịch vụ thành công' : 'Thêm phí dịch vụ thành công'),
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
    final viewModel = context.watch<PhiDichVuViewModel>();
    final isEdit = widget.phiDichVu != null;

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
              _buildAppbar(context, isEdit),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'TÊN DỊCH VỤ *',
                        hint: 'Nhập tên phí dịch vụ (ví dụ: Phí quản lý căn hộ)',
                        controller: _tenPhiDichVuController,
                        prefixIcon: Icons.room_service_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'LOẠI PHÍ DỊCH VỤ *',
                        value: _selectedLoaiPhiId,
                        hint: 'Chọn loại phí',
                        prefixIcon: Icons.category_rounded,
                        onChanged: (val) => setState(() => _selectedLoaiPhiId = val),
                        items: viewModel.feeTypes
                            .map((e) => DropdownMenuItem<int>(
                                  value: e['id'] as int,
                                  child: Text(e['tenLoaiPhiDichVu'] as String? ?? ''),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'ĐƠN GIÁ (VND) *',
                        hint: 'Nhập đơn giá dịch vụ',
                        controller: _donGiaController,
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'ĐƠN VỊ TÍNH *',
                        value: _selectedDonViTinhId,
                        hint: 'Chọn đơn vị',
                        prefixIcon: Icons.scale_rounded,
                        onChanged: (val) => setState(() => _selectedDonViTinhId = val),
                        items: viewModel.unitTypes
                            .map((e) => DropdownMenuItem<int>(
                                  value: e['id'] as int,
                                  child: Text(e['donVi'] as String? ?? ''),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'CÁCH TÍNH PHÍ *',
                        value: _selectedLoaiTinhPhiId,
                        hint: 'Chọn cách tính',
                        prefixIcon: Icons.calculate_rounded,
                        onChanged: (val) => setState(() => _selectedLoaiTinhPhiId = val),
                        items: viewModel.calcTypes
                            .map((e) => DropdownMenuItem<int>(
                                  value: e['id'] as int,
                                  child: Text(e['tenLoai'] as String? ?? ''),
                                ))
                            .toList(),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit ? 'Sửa Phí dịch vụ' : 'Thêm Phí dịch vụ mới',
              style: const TextStyle(
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
