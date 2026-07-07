import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/ViewModels/dat_lich_tien_ich_viewmodel.dart';
import 'package:urbano_manage/Services/dat_lich_tien_ich_service.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';

class DatLichDetailView extends StatefulWidget {
  final DatLichTienIch booking;

  const DatLichDetailView({super.key, required this.booking});

  @override
  State<DatLichDetailView> createState() => _DatLichDetailViewState();
}

class _DatLichDetailViewState extends State<DatLichDetailView> {
  late DatLichTienIch _booking;
  String _role = '';
  int _loggedInStaffId = 0;
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? '';
      final nvStr = prefs.getString('nhanVien');
      int staffId = 0;
      if (nvStr != null) {
        final nvMap = jsonDecode(nvStr) as Map<String, dynamic>;
        staffId = nvMap['id'] as int? ?? 0;
      }
      setState(() {
        _role = role;
        _loggedInStaffId = staffId;
        _isLoadingInfo = false;
      });
    } catch (e) {
      debugPrint('Error loading user info in detail view: $e');
      setState(() {
        _isLoadingInfo = false;
      });
    }
  }

  Future<void> _reloadBooking() async {
    try {
      final updated = await DatLichTienIchService().getById(_booking.id);
      setState(() {
        _booking = updated;
      });
    } catch (e) {
      debugPrint('Error reloading booking: $e');
    }
  }

  Future<void> _handleDuyet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const AppConfirmDialog(
        title: 'Phê duyệt đặt lịch',
        content: 'Bạn có chắc chắn muốn duyệt yêu cầu đặt lịch này không?',
        confirmText: 'DUYỆT',
        cancelText: 'HUY',
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.tealPrimary),
        ),
      );

      final vm = context.read<DatLichTienIchViewModel>();
      final success = await vm.approveBooking(_booking.id);

      if (mounted) {
        Navigator.pop(context); // Pop loading
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã duyệt yêu cầu đặt lịch'), backgroundColor: AppColors.tealPrimary),
          );
          _reloadBooking();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.error ?? 'Lỗi khi duyệt yêu cầu'), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  Future<void> _handleTuChoi() async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Từ chối đặt lịch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vui lòng nhập lý do từ chối đặt lịch tiện ích này:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            AppTextField(
              hint: 'Ví dụ: Trùng lịch bảo trì, quá tải...',
              controller: reasonController,
              prefixIcon: Icons.comment_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý lý do từ chối'), backgroundColor: AppColors.red),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Xác nhận', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    reasonController.dispose();

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.tealPrimary),
        ),
      );

      final vm = context.read<DatLichTienIchViewModel>();
      final success = await vm.rejectBooking(_booking.id, reasonController.text.trim());

      if (mounted) {
        Navigator.pop(context); // Pop loading
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã từ chối đặt lịch thành công'), backgroundColor: AppColors.tealPrimary),
          );
          _reloadBooking();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.error ?? 'Lỗi khi từ chối yêu cầu'), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  Future<void> _handleHuy() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const AppConfirmDialog(
        title: 'Hủy đặt lịch',
        content: 'Bạn có chắc chắn muốn hủy yêu cầu đặt lịch này không?',
        confirmText: 'HỦY LỊCH',
        cancelText: 'QUAY LẠI',
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.tealPrimary),
        ),
      );

      final vm = context.read<DatLichTienIchViewModel>();
      final success = await vm.cancelBooking(_booking.id);

      if (mounted) {
        Navigator.pop(context); // Pop loading
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hủy đặt lịch thành công'), backgroundColor: AppColors.tealPrimary),
          );
          _reloadBooking();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.error ?? 'Lỗi khi hủy đặt lịch'), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final timeStr = '${df.format(_booking.thoiGianBatDau.toLocal())} - ${df.format(_booking.thoiGianKetThuc.toLocal())}';

    Color statusColor;
    switch (_booking.trangThai) {
      case 1:
        statusColor = AppColors.amber;
        break;
      case 2:
        statusColor = AppColors.blue;
        break;
      case 3:
        statusColor = AppColors.red;
        break;
      case 4:
        statusColor = AppColors.textMuted;
        break;
      case 5:
        statusColor = AppColors.tealPrimary;
        break;
      default:
        statusColor = AppColors.red;
    }

    final isQuanLy = _role == 'Quản lý';
    final isChoDuyet = _booking.trangThai == 1;

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
                child: _isLoadingInfo
                    ? const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
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
                                      Expanded(
                                        child: Text(
                                          _booking.tenTienIch,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                        ),
                                        child: Text(
                                          _booking.trangThaiText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Mã đặt lịch: ${_booking.maDatLich}',
                                    style: const TextStyle(color: AppColors.tealPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const Divider(color: AppColors.borderButton, height: 24, thickness: 1),
                                  _buildDetailRow(Icons.person_rounded, 'Cư dân', _booking.tenCuDan),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.apartment_rounded, 'Căn hộ',
                                      _booking.soCanHo.isNotEmpty ? _booking.soCanHo : 'Chưa chọn'),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.access_time_rounded, 'Thời gian', timeStr),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.people_rounded, 'Số người tham gia', '${_booking.soNguoi} người'),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.monetization_on_rounded, 'Phí sử dụng', currencyFormatter.format(_booking.phiSuDung)),
                                  if (_booking.ghiChu.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _buildDetailRow(Icons.edit_note_rounded, 'Ghi chú', _booking.ghiChu),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_booking.trangThai == 2 || _booking.trangThai == 3 || _booking.trangThai == 4) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.nenContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderButton),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _booking.trangThai == 2 ? 'THÔNG TIN PHÊ DUYỆT' : 'THÔNG TIN HỦY/TỪ CHỐI',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMuted,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (_booking.trangThai == 2) ...[
                                      _buildDetailRow(Icons.badge_rounded, 'Nhân viên duyệt', _booking.tenNhanVienDuyet),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(Icons.calendar_today_rounded, 'Ngày duyệt',
                                          _booking.ngayDuyet != null ? df.format(_booking.ngayDuyet!.toLocal()) : ''),
                                    ] else if (_booking.trangThai == 3) ...[
                                      _buildDetailRow(Icons.badge_rounded, 'Nhân viên từ chối', _booking.tenNhanVienDuyet),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(Icons.calendar_today_rounded, 'Ngày từ chối',
                                          _booking.ngayDuyet != null ? df.format(_booking.ngayDuyet!.toLocal()) : ''),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(Icons.comment_rounded, 'Lý do từ chối', _booking.lyDoHuy),
                                    ] else if (_booking.trangThai == 4) ...[
                                      _buildDetailRow(Icons.calendar_today_rounded, 'Ngày hủy',
                                          _booking.ngayHuy != null ? df.format(_booking.ngayHuy!.toLocal()) : ''),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (isChoDuyet) ...[
                              const SizedBox(height: 16),
                              if (isQuanLy) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check_rounded, color: Colors.white),
                                        label: const Text('PHÊ DUYỆT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.tealPrimary,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: _handleDuyet,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                                        label: const Text('TỪ CHỐI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.red,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: _handleTuChoi,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              ElevatedButton.icon(
                                icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                                label: const Text('HỦY ĐẶT LỊCH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.bgMid,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.borderButton),
                                  ),
                                ),
                                onPressed: _handleHuy,
                              ),
                              const SizedBox(height: 24),
                            ],
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.iconMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.tealPrimary),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(width: 8),
          const Text(
            'Chi tiết Đặt lịch Tiện ích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
