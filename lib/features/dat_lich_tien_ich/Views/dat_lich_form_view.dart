import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/ViewModels/dat_lich_tien_ich_viewmodel.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/core/Widgets/app_searchable_picker.dart';

class DatLichFormView extends StatefulWidget {
  const DatLichFormView({super.key});

  @override
  State<DatLichFormView> createState() => _DatLichFormViewState();
}

class _DatLichFormViewState extends State<DatLichFormView> {
  final _soNguoiController = TextEditingController(text: '1');
  final _ghiChuController = TextEditingController();

  int? _selectedTienIchId;
  int? _selectedCuDanId;
  int? _selectedCanHoId;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  double _phiSuDung = 0.0;

  @override
  void initState() {
    super.initState();
    final vm = context.read<DatLichTienIchViewModel>();
    if (vm.utilities.isNotEmpty) {
      _selectedTienIchId = vm.utilities.first.id;
      _phiSuDung = vm.utilities.first.phiSuDung;
    }
    if (vm.residents.isNotEmpty) {
      _selectedCuDanId = vm.residents.first.id;
    }
    if (vm.apartments.isNotEmpty) {
      _selectedCanHoId = vm.apartments.first.id;
    }
    _selectedStart = DateTime.now().add(const Duration(hours: 1));
    // Default duration: 1 hour
    _selectedEnd = _selectedStart!.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _soNguoiController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDateTime(BuildContext context, DateTime? initialVal) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialVal ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (date == null) return null;

    if (!context.mounted) return null;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialVal ?? DateTime.now()),
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
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  Future<void> _saveForm() async {
    final count = int.tryParse(_soNguoiController.text.trim()) ?? 1;
    final note = _ghiChuController.text.trim();

    if (_selectedTienIchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn tiện ích')));
      return;
    }
    if (_selectedCuDanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn cư dân')));
      return;
    }
    if (_selectedStart == null || _selectedEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn thời gian bắt đầu và kết thúc')));
      return;
    }
    if (_selectedEnd!.isBefore(_selectedStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thời gian kết thúc phải sau thời gian bắt đầu')));
      return;
    }

    // Matching C# DTO field format: cuDanId, canHoId, tienIchId, thoiGianBatDau, thoiGianKetThuc, soNguoi, ghiChu
    final data = {
      'cuDanId': _selectedCuDanId,
      'canHoId': _selectedCanHoId,
      'tienIchId': _selectedTienIchId,
      'thoiGianBatDau': _selectedStart!.toIso8601String(),
      'thoiGianKetThuc': _selectedEnd!.toIso8601String(),
      'soNguoi': count,
      'ghiChu': note,
    };

    final viewModel = context.read<DatLichTienIchViewModel>();
    final success = await viewModel.createBooking(data);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tạo lịch đặt tiện ích thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Đã xảy ra lỗi khi tạo lịch đặt'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DatLichTienIchViewModel>();
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

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
              _buildAppbar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSearchablePicker<TienIch>(
                        label: 'CHỌN TIỆN ÍCH *',
                        value: vm.utilities.where((u) => u.id == _selectedTienIchId).firstOrNull,
                        hint: 'Chọn tiện ích',
                        prefixIcon: Icons.pool_rounded,
                        items: vm.utilities,
                        isLoading: vm.isLoading,
                        itemAsString: (ut) => ut.tenTienIch,
                        searchFn: (ut, query) => ut.tenTienIch.toLowerCase().contains(query),
                        onChanged: (val) {
                          setState(() {
                            _selectedTienIchId = val.id;
                            _phiSuDung = val.phiSuDung;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      AppSearchablePicker<CuDan>(
                        label: 'CƯ DÂN ĐẶT *',
                        value: vm.residents.where((c) => c.id == _selectedCuDanId).firstOrNull,
                        hint: 'Chọn cư dân',
                        prefixIcon: Icons.person_rounded,
                        items: vm.residents,
                        isLoading: vm.isLoading,
                        itemAsString: (cd) => '${cd.hoTenDem} ${cd.ten} (${cd.sdt})',
                        searchFn: (cd, query) {
                          return '${cd.hoTenDem} ${cd.ten}'.toLowerCase().contains(query) ||
                                 cd.sdt.toLowerCase().contains(query);
                        },
                        onChanged: (val) {
                          setState(() {
                            _selectedCuDanId = val.id;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      AppSearchablePicker<CanHo?>(
                        label: 'CĂN HỘ',
                        value: _selectedCanHoId == null ? null : vm.apartments.where((ch) => ch.id == _selectedCanHoId).firstOrNull,
                        hint: 'Chọn căn hộ (nếu có)',
                        prefixIcon: Icons.apartment_rounded,
                        items: [null, ...vm.apartments],
                        isLoading: vm.isLoading,
                        itemAsString: (ch) => ch == null ? 'Không chọn căn hộ' : 'Căn hộ ${ch.soCanHo} (${ch.tenToaNha})',
                        searchFn: (ch, query) {
                          if (ch == null) return 'không chọn căn hộ'.contains(query);
                          return ch.soCanHo.toLowerCase().contains(query) || ch.tenToaNha.toLowerCase().contains(query);
                        },
                        onChanged: (val) {
                          setState(() {
                            _selectedCanHoId = val?.id;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final dt = await _selectDateTime(context, _selectedStart);
                                if (dt != null) {
                                  setState(() {
                                    _selectedStart = dt;
                                    if (_selectedEnd == null || _selectedEnd!.isBefore(dt)) {
                                      _selectedEnd = dt.add(const Duration(hours: 1));
                                    }
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: AppTextField(
                                  label: 'THỜI GIAN BẮT ĐẦU *',
                                  hint: 'Chọn ngày giờ',
                                  controller: TextEditingController(
                                    text: _formatDateTime(_selectedStart),
                                  ),
                                  prefixIcon: Icons.calendar_today_rounded,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final dt = await _selectDateTime(context, _selectedEnd);
                                if (dt != null) {
                                  setState(() {
                                    _selectedEnd = dt;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: AppTextField(
                                  label: 'THỜI GIAN KẾT THÚC *',
                                  hint: 'Chọn ngày giờ',
                                  controller: TextEditingController(
                                    text: _formatDateTime(_selectedEnd),
                                  ),
                                  prefixIcon: Icons.calendar_month_rounded,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'SỐ NGƯỜI SỬ DỤNG *',
                        hint: 'Ví dụ: 2',
                        controller: _soNguoiController,
                        prefixIcon: Icons.people_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'GHI CHÚ',
                        hint: 'Ví dụ: Đặt kèm bóng vợt, tổ chức sinh nhật...',
                        controller: _ghiChuController,
                        prefixIcon: Icons.edit_note_rounded,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.tealPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PHÍ SỬ DỤNG DỰ KIẾN:',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(_phiSuDung),
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      vm.isLoading
                          ? Center(child: CircularProgressIndicator(color: AppColors.tealPrimary))
                          : AppButton(
                              label: 'XÁC NHẬN ĐẶT LỊCH',
                              onPressed: _saveForm,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.tealPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Đặt lịch Tiện ích Mới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
