import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:urbano_manage/Services/bao_cao_service.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/features/hoa_don/Views/hoa_don_form_view.dart';

class HoaDonDetailView extends StatefulWidget {
  final HoaDon hoaDon;

  const HoaDonDetailView({super.key, required this.hoaDon});

  @override
  State<HoaDonDetailView> createState() => _HoaDonDetailViewState();
}

class _HoaDonDetailViewState extends State<HoaDonDetailView> {
  late HoaDon _currentHoaDon;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _currentHoaDon = widget.hoaDon;
    _loadRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HoaDonViewModel>().fetchChiTiets(_currentHoaDon.id);
    });
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => HoaDonFormView(hoaDon: _currentHoaDon)),
    );

    if (result == true && mounted) {
      final vm = context.read<HoaDonViewModel>();
      final updated = vm.hoaDons.firstWhere(
        (h) => h.id == _currentHoaDon.id,
        orElse: () => _currentHoaDon,
      );
      setState(() {
        _currentHoaDon = updated;
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa hóa đơn ${_currentHoaDon.maThanhToan} khỏi hệ thống?',
    );

    if (confirm == true && mounted) {
      final success = await context.read<HoaDonViewModel>().removeHoaDon(_currentHoaDon.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa hóa đơn thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<HoaDonViewModel>().error ?? 'Không thể xóa hóa đơn'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddChiTietDialog() async {
    final tenController = TextEditingController();
    final donGiaController = TextEditingController();
    final soLuongController = TextEditingController();
    final chiSoCuController = TextEditingController();
    final chiSoMoiController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgMid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderButton),
          ),
          title: const Text('Thêm phí dịch vụ chi tiết', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  hint: 'Ví dụ: Tiền nước, Tiền điện',
                  label: 'TÊN DỊCH VỤ *',
                  controller: tenController,
                  prefixIcon: Icons.room_service_rounded,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Nhập đơn giá',
                  label: 'ĐƠN GIÁ (VND) *',
                  controller: donGiaController,
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Nhập số lượng',
                  label: 'SỐ LƯỢNG *',
                  controller: soLuongController,
                  prefixIcon: Icons.production_quantity_limits_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Không bắt buộc',
                  label: 'CHỈ SỐ CŨ',
                  controller: chiSoCuController,
                  prefixIcon: Icons.arrow_back_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Không bắt buộc',
                  label: 'CHỈ SỐ MỚI',
                  controller: chiSoMoiController,
                  prefixIcon: Icons.arrow_forward_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final name = tenController.text.trim();
                final price = double.tryParse(donGiaController.text.trim()) ?? 0.0;
                final qty = double.tryParse(soLuongController.text.trim()) ?? 0.0;

                if (name.isEmpty || price <= 0 || qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng điền đầy đủ các trường bắt buộc')),
                  );
                  return;
                }

                final data = {
                  'tenPhiDichVu': name,
                  'donGia': price,
                  'soLuong': qty,
                  'chiSoCu': int.tryParse(chiSoCuController.text.trim()),
                  'chiSoMoi': int.tryParse(chiSoMoiController.text.trim()),
                };

                Navigator.pop(context); // Close dialog

                final success = await this.context.read<HoaDonViewModel>().addChiTietItem(_currentHoaDon.id, data);
                if (success && mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Thêm phí dịch vụ thành công'), backgroundColor: AppColors.tealPrimary),
                  );
                  // Update current invoice totals since they changed on server
                  final vm = this.context.read<HoaDonViewModel>();
                  final updated = vm.hoaDons.firstWhere(
                    (h) => h.id == _currentHoaDon.id,
                    orElse: () => _currentHoaDon,
                  );
                  setState(() {
                    _currentHoaDon = updated;
                  });
                }
              },
              child: const Text('Thêm', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    tenController.dispose();
    donGiaController.dispose();
    soLuongController.dispose();
    chiSoCuController.dispose();
    chiSoMoiController.dispose();
  }

  Future<void> _showPayDialog() async {
    final amountController = TextEditingController(
      text: (_currentHoaDon.tongTien - _currentHoaDon.soTienDaThanhToan).toInt().toString(),
    );
    final refController = TextEditingController(
      text: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
    );
    final noteController = TextEditingController();
    String method = 'Chuyển khoản';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.bgMid,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderButton),
            ),
            title: const Text('Ghi nhận thanh toán', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    hint: 'Nhập số tiền',
                    label: 'SỐ TIỀN THANH TOÁN (VND) *',
                    controller: amountController,
                    prefixIcon: Icons.price_check_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  AppDropdownField<String>(
                    label: 'PHƯƠNG THỨC *',
                    value: method,
                    hint: 'Chọn phương thức',
                    prefixIcon: Icons.payment_rounded,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => method = val);
                    },
                    items: const [
                      DropdownMenuItem(value: 'Chuyển khoản', child: Text('Chuyển khoản')),
                      DropdownMenuItem(value: 'Tiền mặt', child: Text('Tiền mặt')),
                      DropdownMenuItem(value: 'Ví điện tử', child: Text('Ví điện tử')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Nhập mã giao dịch',
                    label: 'MÃ GIAO DỊCH',
                    controller: refController,
                    prefixIcon: Icons.receipt_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Nhập ghi chú',
                    label: 'GHI CHÚ',
                    controller: noteController,
                    prefixIcon: Icons.notes_rounded,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                  final ref = refController.text.trim();

                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập số tiền thanh toán hợp lệ')),
                    );
                    return;
                  }

                  final note = noteController.text.trim();
                  
                  Navigator.pop(context); // Close dialog

                  final data = {
                    'soTien': amount,
                    'phuongThucThanhToan': method,
                    'maGiaoDich': ref,
                    'ghiChu': note,
                  };

                  final success = await this.context.read<HoaDonViewModel>().recordPayment(_currentHoaDon.id, data);
                  if (success && mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Ghi nhận thanh toán thành công'), backgroundColor: AppColors.tealPrimary),
                    );
                    // Refresh view model and update current invoice details
                    final vm = this.context.read<HoaDonViewModel>();
                    final updated = vm.hoaDons.firstWhere(
                      (h) => h.id == _currentHoaDon.id,
                      orElse: () => _currentHoaDon,
                    );
                    setState(() {
                      _currentHoaDon = updated;
                    });
                  }
                },
                child: const Text('Thanh toán', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );

    amountController.dispose();
    refController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedDueDate = _currentHoaDon.hanThanhToan != null
        ? DateFormat('dd/MM/yyyy').format(_currentHoaDon.hanThanhToan!.toLocal())
        : 'Chưa cập nhật';
    final formattedCreatedAt = DateFormat('dd/MM/yyyy HH:mm').format(_currentHoaDon.createdAt.toLocal());
    
    Color statusColor;
    switch (_currentHoaDon.trangThai) {
      case 1:
        statusColor = AppColors.red;
        break;
      case 2:
        statusColor = AppColors.amber;
        break;
      case 3:
        statusColor = AppColors.tealPrimary;
        break;
      default:
        statusColor = AppColors.red;
    }

    final conThieu = _currentHoaDon.tongTien - _currentHoaDon.soTienDaThanhToan;
    final details = context.watch<HoaDonViewModel>().currentChiTiets;

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
              _buildAppbar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeaderCard(statusColor, currencyFormat),
                      const SizedBox(height: 20),
                      if (conThieu > 0) ...[
                        AppButton(
                          label: 'Ghi Nhận Thanh Toán',
                          icon: Icons.payments_rounded,
                          onPressed: _showPayDialog,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildInfoSection('Chi tiết hóa đơn', [
                        _buildInfoRow(Icons.apartment_rounded, 'Căn hộ ID', _currentHoaDon.canHo.toString()),
                        _buildInfoRow(Icons.calendar_view_month_rounded, 'Kỳ hóa đơn', 'Tháng ${_currentHoaDon.thang}/${_currentHoaDon.nam}'),
                        _buildInfoRow(Icons.timer_rounded, 'Hạn thanh toán', formattedDueDate),
                      ]),
                      const SizedBox(height: 16),
                      _buildChiTietSection(currencyFormat),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin thanh toán', [
                        _buildInfoRow(Icons.price_change_rounded, 'Chi phí dịch vụ', currencyFormat.format(_currentHoaDon.chiPhi)),
                        _buildInfoRow(Icons.payment_rounded, 'Đã thanh toán', currencyFormat.format(_currentHoaDon.soTienDaThanhToan)),
                        _buildInfoRow(Icons.money_off_rounded, 'Còn thiếu', currencyFormat.format(conThieu < 0 ? 0.0 : conThieu)),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin cập nhật', [
                        _buildInfoRow(Icons.person_outline_rounded, 'Người cập nhật', _currentHoaDon.tenNguoiCapNhat.isNotEmpty ? _currentHoaDon.tenNguoiCapNhat : 'N/A'),
                        _buildInfoRow(Icons.calendar_today_rounded, 'Ngày khởi tạo', formattedCreatedAt),
                      ]),
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
    final isQuanLy = _role == 'Quản lý';
    final isKeToan = _role == 'Kế toán' || isQuanLy;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true), // Return true to refresh list if needed
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
          const Expanded(
            child: Text(
              'Chi tiết Hóa đơn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          if (isKeToan) ...[
            GestureDetector(
              onTap: _exportBienLaiPdf,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderButton),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: AppColors.tealPrimary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: () => _navigateToEdit(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: const Icon(Icons.edit_rounded, size: 18, color: AppColors.tealPrimary),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: const Icon(Icons.delete_rounded, size: 18, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color statusColor, NumberFormat currencyFormat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentHoaDon.maThanhToan,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _currentHoaDon.trangThaiText,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'TỔNG TIỀN THANH TOÁN',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(_currentHoaDon.tongTien),
            style: TextStyle(color: statusColor, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChiTietSection(NumberFormat currencyFormat) {
    final details = context.watch<HoaDonViewModel>().currentChiTiets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phí dịch vụ chi tiết',
                style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.8),
              ),
              GestureDetector(
                onTap: _showAddChiTietDialog,
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: AppColors.tealPrimary, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Thêm',
                      style: TextStyle(color: AppColors.tealPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderButton),
          ),
          child: details.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Center(
                    child: Text(
                      'Chưa có dịch vụ chi tiết nào cho hóa đơn này.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: details.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.borderButton, height: 1),
                  itemBuilder: (context, index) {
                    final item = details[index];
                    final name = item['tenPhiDichVu'] as String? ?? 'Dịch vụ';
                    final donGia = (item['donGia'] as num? ?? 0).toDouble();
                    final qty = (item['soLuong'] as num? ?? 0).toDouble();
                    final total = (item['thanhTien'] as num? ?? 0).toDouble();
                    final sc = item['chiSoCu'] as int?;
                    final sm = item['chiSoMoi'] as int?;

                    String subtitle = '${qty.toStringAsFixed(0)} x ${currencyFormat.format(donGia)}';
                    if (sc != null && sm != null) {
                      subtitle += ' (Chỉ số: $sc ➔ $sm)';
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(total),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String sectionTitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            sectionTitle,
            style: const TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.8),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderButton),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.iconMuted, size: 18),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBienLaiPdf() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xuất PDF không khả dụng trên Flutter Web'), backgroundColor: AppColors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
    );

    try {
      final service = BaoCaoService();
      final bytes = await service.getBienLaiPdf(_currentHoaDon.id);
      
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/BienLai_HoaDon_${_currentHoaDon.maThanhToan}.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading

      final openResult = await OpenFile.open(path);
      if (openResult.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở file: ${openResult.message}'), backgroundColor: AppColors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }
}
