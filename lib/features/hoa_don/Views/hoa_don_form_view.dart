import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/core/Widgets/app_searchable_picker.dart';
import 'package:urbano_manage/core/Widgets/app_date_picker.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';

class HoaDonFormView extends StatefulWidget {
  final HoaDon? hoaDon;

  const HoaDonFormView({super.key, this.hoaDon});

  @override
  State<HoaDonFormView> createState() => _HoaDonFormViewState();
}

class _HoaDonFormViewState extends State<HoaDonFormView> {
  final _maThanhToanController = TextEditingController();
  final _thangController = TextEditingController();
  final _namController = TextEditingController();
  final _tongTienController = TextEditingController();
  final _daThanhToanController = TextEditingController();
  final _chiPhiController = TextEditingController();

  int? _selectedCanHoId;
  DateTime? _selectedDueDate;
  int _selectedTrangThai = 1; // 1: Chưa thanh toán, 2: Thanh toán một phần, 3: Đã thanh toán

  List<CanHo> _apartments = [];
  bool _isLoadingApartments = false;

  @override
  void initState() {
    super.initState();
    _loadApartments();

    final now = DateTime.now();
    _thangController.text = now.month.toString();
    _namController.text = now.year.toString();
    _tongTienController.text = '0';
    _daThanhToanController.text = '0';
    _chiPhiController.text = '0';

    if (widget.hoaDon != null) {
      final h = widget.hoaDon!;
      _maThanhToanController.text = h.maThanhToan;
      _thangController.text = h.thang.toString();
      _namController.text = h.nam.toString();
      _tongTienController.text = h.tongTien.toInt().toString();
      _daThanhToanController.text = h.soTienDaThanhToan.toInt().toString();
      _chiPhiController.text = h.chiPhi.toInt().toString();
      _selectedCanHoId = h.canHo;
      _selectedDueDate = h.hanThanhToan;
      _selectedTrangThai = h.trangThai;
    } else {
      _maThanhToanController.text = 'HD-${DateTime.now().millisecondsSinceEpoch}';
      _selectedDueDate = DateTime.now().add(const Duration(days: 15));
    }
  }

  @override
  void dispose() {
    _maThanhToanController.dispose();
    _thangController.dispose();
    _namController.dispose();
    _tongTienController.dispose();
    _daThanhToanController.dispose();
    _chiPhiController.dispose();
    super.dispose();
  }

  Future<void> _loadApartments() async {
    setState(() => _isLoadingApartments = true);
    try {
      final apartments = await CanHoService().fetchCanHos();
      if (!mounted) return;
      setState(() {
        _apartments = apartments;
        if (widget.hoaDon == null && apartments.isNotEmpty) {
          _selectedCanHoId = apartments.first.id;
        }
      });
    } catch (e) {
      debugPrint('Error loading apartments: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingApartments = false);
      }
    }
  }

  Future<void> _saveForm() async {
    final maThanhToan = _maThanhToanController.text.trim();
    final thang = int.tryParse(_thangController.text.trim()) ?? 0;
    final nam = int.tryParse(_namController.text.trim()) ?? 0;
    final tongTien = double.tryParse(_tongTienController.text.trim()) ?? 0.0;
    final daThanhToan = double.tryParse(_daThanhToanController.text.trim()) ?? 0.0;
    final chiPhi = double.tryParse(_chiPhiController.text.trim()) ?? 0.0;

    if (maThanhToan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Mã thanh toán')));
      return;
    }
    if (_selectedCanHoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn Căn hộ')));
      return;
    }
    if (thang < 1 || thang > 12) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tháng không hợp lệ (1-12)')));
      return;
    }
    if (nam < 2000 || nam > 2100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Năm không hợp lệ (2000-2100)')));
      return;
    }

    final data = {
      'maThanhToan': maThanhToan,
      'canHo': _selectedCanHoId,
      'thang': thang,
      'nam': nam,
      'tongTien': tongTien,
      'soTienDaThanhToan': daThanhToan,
      'chiPhi': chiPhi,
      'hanThanhToan': _selectedDueDate?.toIso8601String(),
      'trangThai': _selectedTrangThai,
    };

    final viewModel = context.read<HoaDonViewModel>();
    bool success;
    if (widget.hoaDon != null) {
      success = await viewModel.editHoaDon(widget.hoaDon!.id, data);
    } else {
      success = await viewModel.addHoaDon(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.hoaDon != null ? 'Cập nhật hóa đơn thành công' : 'Tạo hóa đơn thành công'),
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
    final viewModel = context.watch<HoaDonViewModel>();
    final isEdit = widget.hoaDon != null;

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
                        label: 'MÃ THANH TOÁN *',
                        hint: 'Nhập mã thanh toán hóa đơn',
                        controller: _maThanhToanController,
                        prefixIcon: Icons.qr_code_rounded,
                      ),
                      const SizedBox(height: 16),
                      _isLoadingApartments
                          ? const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary))
                          : AppSearchablePicker<CanHo>(
                              label: 'CĂN HỘ *',
                              value: _apartments.cast<CanHo?>().firstWhere(
                                (c) => c?.id == _selectedCanHoId, 
                                orElse: () => null,
                              ),
                              hint: 'Chọn căn hộ',
                              prefixIcon: Icons.apartment_rounded,
                              items: _apartments,
                              itemAsString: (c) => '${c.tenToaNha} - Căn ${c.soCanHo}',
                              searchFn: (c, query) {
                                return c.tenToaNha.toLowerCase().contains(query) ||
                                       c.soCanHo.toLowerCase().contains(query);
                              },
                              onChanged: (val) {
                                setState(() => _selectedCanHoId = val.id);
                              },
                            ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'THÁNG *',
                              hint: 'Nhập tháng',
                              controller: _thangController,
                              prefixIcon: Icons.calendar_month_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'NĂM *',
                              hint: 'Nhập năm',
                              controller: _namController,
                              prefixIcon: Icons.calendar_today_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppDatePicker(
                        label: 'HẠN THANH TOÁN',
                        hint: 'Chọn hạn thanh toán',
                        selectedDate: _selectedDueDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDueDate = date);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'CHI PHÍ DỊCH VỤ (VND)',
                        hint: 'Nhập chi phí',
                        controller: _chiPhiController,
                        prefixIcon: Icons.room_service_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'TỔNG TIỀN (VND) *',
                        hint: 'Nhập tổng số tiền cần thanh toán',
                        controller: _tongTienController,
                        prefixIcon: Icons.monetization_on_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'ĐÃ THANH TOÁN (VND)',
                        hint: 'Nhập số tiền đã trả',
                        controller: _daThanhToanController,
                        prefixIcon: Icons.price_check_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'TRẠNG THÁI THANH TOÁN',
                        value: _selectedTrangThai,
                        hint: 'Chọn trạng thái',
                        prefixIcon: Icons.payment_rounded,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTrangThai = val);
                        },
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Chưa thanh toán')),
                          DropdownMenuItem(value: 2, child: Text('Thanh toán một phần')),
                          DropdownMenuItem(value: 3, child: Text('Đã thanh toán')),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: viewModel.isLoading ? 'Đang xử lý...' : (isEdit ? 'Cập Nhật' : 'Tạo Mới'),
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
              isEdit ? 'Sửa thông tin Hóa đơn' : 'Tạo Hóa đơn mới',
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
