import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/core/Widgets/app_date_picker.dart';
import 'package:urbano_manage/core/utils/app_validators.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/features/hoa_don/Views/batch_result_dialog.dart';

class BatchInvoiceDialog extends StatefulWidget {
  const BatchInvoiceDialog({super.key});

  @override
  State<BatchInvoiceDialog> createState() => _BatchInvoiceDialogState();
}

class _BatchInvoiceDialogState extends State<BatchInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _thangController = TextEditingController(text: DateTime.now().month.toString());
  final _namController = TextEditingController(text: DateTime.now().year.toString());
  
  int? _selectedToaNhaId; // null = Tất cả tòa nhà
  DateTime? _selectedDueDate;
  int _employeeId = 1;

  bool _includeManagementFee = true;
  bool _includeParkingFee = true;

  @override
  void initState() {
    super.initState();
    // Default due date to 15th of current month or 15 days from now
    final now = DateTime.now();
    _selectedDueDate = DateTime(now.year, now.month, 15);
    if (_selectedDueDate!.isBefore(now)) {
      _selectedDueDate = now.add(const Duration(days: 14));
    }
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CanHoViewModel>().fetchLookups();
    });
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _employeeId = prefs.getInt('employeeId') ?? prefs.getInt('userId') ?? 1;
    });
  }

  Future<void> _submitBatch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final thang = int.parse(_thangController.text.trim());
    final nam = int.parse(_namController.text.trim());

    final vm = context.read<HoaDonViewModel>();

    final List<String> selectedFeeTypes = [];
    if (_includeManagementFee) selectedFeeTypes.add('MANAGEMENT');
    if (_includeParkingFee) selectedFeeTypes.add('PARKING');

    final result = await vm.runAutoBilling(
      thang,
      nam,
      _employeeId,
      toaNhaId: _selectedToaNhaId,
      hanThanhToan: _selectedDueDate,
      feeTypes: selectedFeeTypes,
    );

    if (mounted) {
      if (result != null) {
        Navigator.of(context).pop(true);
        showDialog(
          context: context,
          builder: (_) => BatchResultDialog(result: result),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Đã xảy ra lỗi khi tạo hóa đơn hàng loạt'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canHoVm = context.watch<CanHoViewModel>();
    final hoaDonVm = context.watch<HoaDonViewModel>();

    final buildings = canHoVm.buildings;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSide, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.tealPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.auto_mode_rounded, color: AppColors.tealPrimary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PHÁT HÀNH HÓA ĐƠN HÀNG LOẠT',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppColors.iconMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'THÁNG BÁO CÁO *',
                        hint: 'Tháng',
                        controller: _thangController,
                        prefixIcon: Icons.calendar_month_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final t = int.tryParse(v ?? '');
                          if (t == null || t < 1 || t > 12) return '1-12';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'NĂM *',
                        hint: 'Năm',
                        controller: _namController,
                        prefixIcon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 2000 || n > 2100) return '2000-2100';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppDropdownField<int?>(
                  label: 'PHẠM VI TÒA NHÀ',
                  value: _selectedToaNhaId,
                  hint: 'Tất cả các tòa nhà',
                  prefixIcon: Icons.business_rounded,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả các tòa nhà'),
                    ),
                    ...buildings.map((b) => DropdownMenuItem<int?>(
                          value: b['id'] as int,
                          child: Text(b['tenToaNha'] as String? ?? 'Tòa nhà ${b['id']}'),
                        )),
                  ],
                  onChanged: (val) => setState(() => _selectedToaNhaId = val),
                ),
                const SizedBox(height: 16),
                AppDatePicker(
                  label: 'HẠN THANH TOÁN MẶC ĐỊNH',
                  hint: 'Chọn hạn thanh toán',
                  selectedDate: _selectedDueDate,
                  onDateSelected: (date) => setState(() => _selectedDueDate = date),
                ),
                const SizedBox(height: 20),
                Text(
                  'CÁC DANH MỤC PHÍ TỰ ĐỘNG GOM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                _buildFeeToggle(
                  title: 'Phí quản lý căn hộ',
                  subtitle: 'Tự động tính theo Diện tích × Đơn giá',
                  value: _includeManagementFee,
                  onChanged: (val) => setState(() => _includeManagementFee = val),
                ),
                const SizedBox(height: 8),
                _buildFeeToggle(
                  title: 'Phí giữ xe / Phương tiện',
                  subtitle: 'Tự động tính theo số lượng phương tiện đăng ký',
                  value: _includeParkingFee,
                  onChanged: (val) => setState(() => _includeParkingFee = val),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.tealPrimary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hệ thống tự động bỏ qua các căn hộ đã có hóa đơn trong kỳ này để tránh tạo trùng lặp.',
                          style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'PHÁT HÀNH HÓA ĐƠN HÀNG LOẠT',
                  isLoading: hoaDonVm.isLoading,
                  onPressed: _submitBatch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.tealPrimary,
        title: Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
