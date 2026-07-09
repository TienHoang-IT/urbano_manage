import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_searchable_picker.dart';
import 'package:urbano_manage/core/Widgets/app_date_picker.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';
import 'package:urbano_manage/Models/phi_dich_vu_model.dart';
import 'package:urbano_manage/Services/phi_dich_vu_service.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';

class HoaDonFormView extends StatefulWidget {
  final HoaDon? hoaDon;

  const HoaDonFormView({super.key, this.hoaDon});

  @override
  State<HoaDonFormView> createState() => _HoaDonFormViewState();
}

class _ChiTietItem {
  TextEditingController tenController;
  TextEditingController donGiaController;
  TextEditingController soLuongController;
  TextEditingController chiSoCuController;
  TextEditingController chiSoMoiController;

  _ChiTietItem({
    String ten = '',
    String donGia = '0',
    String soLuong = '1',
    String? chiSoCu,
    String? chiSoMoi,
  })  : tenController = TextEditingController(text: ten),
        donGiaController = TextEditingController(text: donGia),
        soLuongController = TextEditingController(text: soLuong),
        chiSoCuController = TextEditingController(text: chiSoCu ?? ''),
        chiSoMoiController = TextEditingController(text: chiSoMoi ?? '');

  void dispose() {
    tenController.dispose();
    donGiaController.dispose();
    soLuongController.dispose();
    chiSoCuController.dispose();
    chiSoMoiController.dispose();
  }
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
  List<PhiDichVu> _phiDichVus = [];
  List<_ChiTietItem> _chiTiets = [];
  bool _isLoadingChiTiets = false;

  @override
  void initState() {
    super.initState();
    _loadApartments();
    _loadPhiDichVus();

    final now = DateTime.now();
    _thangController.text = now.month.toString();
    _namController.text = now.year.toString();
    _tongTienController.text = '0';
    _daThanhToanController.text = '0';
    _chiPhiController.text = '0';

    if (widget.hoaDon != null) {
      final h = widget.hoaDon!;
      _loadChiTiets(h.id);
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
      _maThanhToanController.text = 'HD${DateTime.now().millisecondsSinceEpoch}';
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
    for (var item in _chiTiets) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _loadChiTiets(int hoaDonId) async {
    setState(() => _isLoadingChiTiets = true);
    try {
      final vm = context.read<HoaDonViewModel>();
      await vm.fetchChiTiets(hoaDonId);
      final details = vm.currentChiTiets;
      if (mounted) {
        setState(() {
          _chiTiets = details.map((d) => _ChiTietItem(
            ten: d['tenPhiDichVu']?.toString() ?? '',
            donGia: d['donGia']?.toString() ?? '0',
            soLuong: d['soLuong']?.toString() ?? '1',
            chiSoCu: d['chiSoCu']?.toString(),
            chiSoMoi: d['chiSoMoi']?.toString(),
          )).toList();
          _calculateTongTien();
          _isLoadingChiTiets = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingChiTiets = false);
    }
  }

  void _calculateTongTien() {
    double total = 0;
    for (var item in _chiTiets) {
      final donGia = double.tryParse(item.donGiaController.text.trim()) ?? 0;
      final soLuong = double.tryParse(item.soLuongController.text.trim()) ?? 0;
      total += (donGia * soLuong);
    }
    _tongTienController.text = total.toStringAsFixed(0);
  }

  Future<void> _loadPhiDichVus() async {
    try {
      final list = await PhiDichVuService().fetchPhiDichVus();
      if (mounted) setState(() => _phiDichVus = list);
    } catch (_) {
    }
  }

  Future<void> _showChiTietDialog(int? index) async {
    final item = index != null ? _chiTiets[index] : _ChiTietItem();
    final isNew = index == null;

    final String backupTen = item.tenController.text;
    final String backupDonGia = item.donGiaController.text;
    final String backupSoLuong = item.soLuongController.text;
    final String backupCu = item.chiSoCuController.text;
    final String backupMoi = item.chiSoMoiController.text;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void onChiSoChangedLocal() {
              final cu = double.tryParse(item.chiSoCuController.text.trim());
              final moi = double.tryParse(item.chiSoMoiController.text.trim());
              if (cu != null && moi != null && moi > cu) {
                item.soLuongController.text = (moi - cu).toStringAsFixed(0);
              }
              setStateDialog(() {});
            }

            return AlertDialog(
              backgroundColor: AppColors.bgMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderButton),
              ),
              title: Text(isNew ? 'Thêm phí dịch vụ' : 'Sửa phí dịch vụ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSearchablePicker<PhiDichVu>(
                      label: 'TÊN DỊCH VỤ *',
                      hint: 'Chọn phí dịch vụ',
                      prefixIcon: Icons.room_service_rounded,
                      value: _phiDichVus.cast<PhiDichVu?>().firstWhere(
                        (p) => p?.tenPhiDichVu == item.tenController.text,
                        orElse: () => null,
                      ),
                      items: _phiDichVus,
                      itemAsString: (p) => p.tenPhiDichVu,
                      searchFn: (p, q) => p.tenPhiDichVu.toLowerCase().contains(q.toLowerCase()),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            item.tenController.text = val.tenPhiDichVu;
                            item.donGiaController.text = val.donGia.toStringAsFixed(0);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'ĐƠN GIÁ *',
                            hint: 'Đơn giá',
                            controller: item.donGiaController,
                            prefixIcon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'SỐ LƯỢNG *',
                            hint: 'Số lượng',
                            controller: item.soLuongController,
                            prefixIcon: Icons.production_quantity_limits_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'CHỈ SỐ CŨ',
                            hint: 'Cũ',
                            controller: item.chiSoCuController,
                            prefixIcon: Icons.arrow_back_rounded,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => onChiSoChangedLocal(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'CHỈ SỐ MỚI',
                            hint: 'Mới',
                            controller: item.chiSoMoiController,
                            prefixIcon: Icons.arrow_forward_rounded,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => onChiSoChangedLocal(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (isNew) {
                      item.dispose();
                    } else {
                      item.tenController.text = backupTen;
                      item.donGiaController.text = backupDonGia;
                      item.soLuongController.text = backupSoLuong;
                      item.chiSoCuController.text = backupCu;
                      item.chiSoMoiController.text = backupMoi;
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    final name = item.tenController.text.trim();
                    final price = double.tryParse(item.donGiaController.text.trim()) ?? 0;
                    final qty = double.tryParse(item.soLuongController.text.trim()) ?? 0;
                    final cu = int.tryParse(item.chiSoCuController.text.trim());
                    final moi = int.tryParse(item.chiSoMoiController.text.trim());
                    
                    if (name.isEmpty || price < 0 || qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền tên, đơn giá và số lượng lớn hơn 0 cho phí dịch vụ')));
                      return;
                    }
                    
                    if (cu != null && moi != null && moi <= cu) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chỉ số mới phải lớn hơn chỉ số cũ')));
                      return;
                    }

                    if (isNew) {
                      setState(() {
                        _chiTiets.add(item);
                      });
                    } else {
                      setState(() {});
                    }
                    _calculateTongTien();
                    Navigator.pop(context);
                  },
                  child: Text(isNew ? 'Thêm' : 'Cập nhật', style: const TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }
    );
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

    List<Map<String, dynamic>> chiTietHoaDons = [];
    for (var item in _chiTiets) {
      final name = item.tenController.text.trim();
      final price = double.tryParse(item.donGiaController.text.trim()) ?? 0;
      final qty = double.tryParse(item.soLuongController.text.trim()) ?? 0;
      final cu = int.tryParse(item.chiSoCuController.text.trim());
      final moi = int.tryParse(item.chiSoMoiController.text.trim());
      
      if (name.isEmpty || price < 0 || qty <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền tên, đơn giá và số lượng lớn hơn 0 cho các phí dịch vụ')));
        return;
      }
      
      if (cu != null && moi != null && moi <= cu) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chỉ số mới phải lớn hơn chỉ số cũ')));
        return;
      }
      
      chiTietHoaDons.add({
        'tenPhiDichVu': name,
        'donGia': price,
        'soLuong': qty,
        'chiSoCu': cu,
        'chiSoMoi': moi,
      });
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
      'chiTietHoaDons': chiTietHoaDons,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DANH SÁCH PHÍ DỊCH VỤ',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showChiTietDialog(null),
                            child: const Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, color: AppColors.tealPrimary, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Thêm phí',
                                  style: TextStyle(color: AppColors.tealPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _isLoadingChiTiets 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary))
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _chiTiets.length,
                          itemBuilder: (context, index) {
                            final item = _chiTiets[index];
                            final donGia = double.tryParse(item.donGiaController.text.trim()) ?? 0;
                            final soLuong = double.tryParse(item.soLuongController.text.trim()) ?? 0;
                            final total = donGia * soLuong;
                            
                            return GestureDetector(
                              onTap: () => _showChiTietDialog(index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderButton),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.tenController.text.isEmpty ? 'Chưa chọn dịch vụ' : item.tenController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text('${soLuong.toStringAsFixed(0)} x ${donGia.toStringAsFixed(0)} = ${total.toStringAsFixed(0)} VND', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                          if (item.chiSoCuController.text.isNotEmpty && item.chiSoMoiController.text.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text('Chỉ số: ${item.chiSoCuController.text} ➔ ${item.chiSoMoiController.text}', style: const TextStyle(color: AppColors.tealPrimary, fontSize: 11)),
                                            ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _chiTiets.removeAt(index).dispose();
                                          _calculateTongTien();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.red.withAlpha(38),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.delete_rounded, color: AppColors.red, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'ĐÃ THANH TOÁN (VND)',
                        hint: 'Số tiền đã trả (chỉ xem)',
                        controller: _daThanhToanController,
                        prefixIcon: Icons.price_check_rounded,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'TỔNG TIỀN (VND) *',
                        hint: 'Tổng số tiền tự động tính từ danh sách',
                        controller: _tongTienController,
                        prefixIcon: Icons.monetization_on_rounded,
                        readOnly: true,
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
