import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/core/utils/app_validators.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';

class BulkMeterEntryDialog extends StatefulWidget {
  const BulkMeterEntryDialog({super.key});

  @override
  State<BulkMeterEntryDialog> createState() => _BulkMeterEntryDialogState();
}

class _BulkMeterEntryDialogState extends State<BulkMeterEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _thangController = TextEditingController(text: DateTime.now().month.toString());
  final _namController = TextEditingController(text: DateTime.now().year.toString());
  
  int? _selectedToaNhaId;
  List<_ApartmentMeterGroup> _groups = [];
  bool _isFetchingServices = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final canHoVm = context.read<CanHoViewModel>();
      await canHoVm.fetchCanHos();
      await canHoVm.fetchLookups();
      if (mounted) {
        _loadApartmentGroups(canHoVm.canHos);
      }
    });
  }

  Future<void> _loadApartmentGroups(List<CanHo> allApartments) async {
    if (_isFetchingServices) return;
    setState(() {
      _isFetchingServices = true;
    });

    final filtered = _selectedToaNhaId == null
        ? allApartments
        : allApartments.where((c) => c.toaNhaId == _selectedToaNhaId).toList();

    final hoaDonVm = context.read<HoaDonViewModel>();
    final List<_ApartmentMeterGroup> loadedGroups = [];

    for (var c in filtered) {
      final servicesFromDb = await hoaDonVm.fetchMeteredServicesForCanHo(c.id);

      final List<_MeterItem> meterItems = [];
      for (var s in servicesFromDb) {
        final feeName = s['tenPhiDichVu'] as String? ?? 'Phí dịch vụ đo đếm';
        final feeId = s['phiDichVuId'] as int? ?? s['id'] as int? ?? 0;
        final unitName = s['tenDonViTinh'] as String? ?? 'Chỉ số';

        // Query real previous meter reading (chiSoCu) from latest DB invoice
        final previousReading = await hoaDonVm.getLatestMeterReading(c.id, feeName);

        meterItems.add(_MeterItem(
          phiDichVuId: feeId,
          tenPhiDichVu: feeName,
          tenDonViTinh: unitName,
          chiSoCu: previousReading,
          chiSoMoiController: TextEditingController(),
        ));
      }

      loadedGroups.add(_ApartmentMeterGroup(
        canHoId: c.id,
        soCanHo: c.soCanHo,
        tenToaNha: c.tenToaNha,
        meterItems: meterItems,
      ));
    }

    if (mounted) {
      setState(() {
        _groups = loadedGroups;
        _isFetchingServices = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _submitReadings() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final thang = int.parse(_thangController.text.trim());
    final nam = int.parse(_namController.text.trim());

    final List<Map<String, dynamic>> readingsPayload = [];
    for (var g in _groups) {
      for (var item in g.meterItems) {
        final chiSoMoi = int.tryParse(item.chiSoMoiController.text.trim());
        if (chiSoMoi != null) {
          readingsPayload.add({
            'canHoId': g.canHoId,
            'phiDichVuId': item.phiDichVuId,
            'tenPhiDichVu': item.tenPhiDichVu,
            'chiSoCu': item.chiSoCu,
            'chiSoMoi': chiSoMoi,
          });
        }
      }
    }

    if (readingsPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ít nhất 1 chỉ số dịch vụ mới')),
      );
      return;
    }

    final vm = context.read<HoaDonViewModel>();
    final success = await vm.submitBulkMeterReadings(thang, nam, readingsPayload);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu ${readingsPayload.length} chỉ số dịch vụ hàng loạt thành công!'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Đã xảy ra lỗi khi lưu chỉ số hàng loạt'),
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
    final buildings = canHoVm.buildings ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 750),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSide, width: 1.5),
        ),
        child: Form(
          key: _formKey,
          child: Column(
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
                        child: Icon(Icons.speed_rounded, color: AppColors.tealPrimary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NHẬP CHỈ SỐ HÀNG LOẠT',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Nhập chỉ số theo phí dịch vụ thực tế từ CSDL',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.iconMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppDropdownField<int?>(
                      label: 'TÒA NHÀ',
                      value: _selectedToaNhaId,
                      hint: 'Tất cả các tòa nhà',
                      prefixIcon: Icons.apartment_rounded,
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('Tất cả tòa nhà')),
                        ...buildings.map((b) => DropdownMenuItem<int?>(
                              value: b['id'] as int,
                              child: Text(b['tenToaNha'] as String? ?? 'Tòa ${b['id']}'),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedToaNhaId = val);
                        _loadApartmentGroups(canHoVm.canHos ?? []);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      label: 'THÁNG *',
                      hint: 'Tháng',
                      controller: _thangController,
                      prefixIcon: Icons.calendar_month_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) => AppValidators.validatePositiveInteger(v, fieldName: 'Tháng'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      label: 'NĂM *',
                      hint: 'Năm',
                      controller: _namController,
                      prefixIcon: Icons.calendar_today_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) => AppValidators.validatePositiveInteger(v, fieldName: 'Năm'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isFetchingServices || !_isInitialized
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.tealPrimary),
                      )
                    : _groups.isEmpty
                        ? Center(
                            child: Text(
                              'Không có căn hộ nào trong phạm vi đã chọn',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _groups.length,
                            itemBuilder: (context, index) {
                              final g = _groups[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderButton),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.home_rounded, color: AppColors.tealPrimary, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Căn ${g.soCanHo} (${g.tenToaNha})',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (g.meterItems.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.nenContainer,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Chưa đăng ký dịch vụ đo đếm chỉ số',
                                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Column(
                                        children: g.meterItems.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.tenPhiDichVu,
                                                        style: TextStyle(
                                                          color: AppColors.textPrimary,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Đơn vị: ${item.tenDonViTinh} | Chỉ số cũ: ${item.chiSoCu}',
                                                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  flex: 2,
                                                  child: AppTextField(
                                                    label: '',
                                                    hint: 'Nhập chỉ số mới',
                                                    controller: item.chiSoMoiController,
                                                    prefixIcon: Icons.pin_rounded,
                                                    keyboardType: TextInputType.number,
                                                    validator: (v) {
                                                      if (v == null || v.trim().isEmpty) return null;
                                                      final val = int.tryParse(v.trim());
                                                      if (val == null || val <= item.chiSoCu) {
                                                        return '> ${item.chiSoCu}';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'LƯU CHỈ SỐ HÀNG LOẠT',
                isLoading: hoaDonVm.isLoading,
                onPressed: _submitReadings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApartmentMeterGroup {
  final int canHoId;
  final String soCanHo;
  final String tenToaNha;
  final List<_MeterItem> meterItems;

  _ApartmentMeterGroup({
    required this.canHoId,
    required this.soCanHo,
    required this.tenToaNha,
    required this.meterItems,
  });
}

class _MeterItem {
  final int phiDichVuId;
  final String tenPhiDichVu;
  final String tenDonViTinh;
  final int chiSoCu;
  final TextEditingController chiSoMoiController;

  _MeterItem({
    required this.phiDichVuId,
    required this.tenPhiDichVu,
    required this.tenDonViTinh,
    required this.chiSoCu,
    required this.chiSoMoiController,
  });
}
