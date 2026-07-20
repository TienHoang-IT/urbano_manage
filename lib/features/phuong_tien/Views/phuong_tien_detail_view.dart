import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/Models/phuong_tien_model.dart';
import 'package:urbano_manage/features/phuong_tien/ViewModels/phuong_tien_viewmodel.dart';
import 'package:urbano_manage/features/phuong_tien/Views/phuong_tien_form_view.dart';

class PhuongTienDetailView extends StatefulWidget {
  final PhuongTien phuongTien;

  const PhuongTienDetailView({super.key, required this.phuongTien});

  @override
  State<PhuongTienDetailView> createState() => _PhuongTienDetailViewState();
}

class _PhuongTienDetailViewState extends State<PhuongTienDetailView> {
  late PhuongTien _currentPhuongTien;

  @override
  void initState() {
    super.initState();
    _currentPhuongTien = widget.phuongTien;
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PhuongTienFormView(phuongTien: _currentPhuongTien)),
    );

    if (result == true && mounted) {
      final vm = context.read<PhuongTienViewModel>();
      final updated = vm.items.firstWhere(
        (p) => p.id == _currentPhuongTien.id,
        orElse: () => _currentPhuongTien,
      );
      setState(() {
        _currentPhuongTien = updated;
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa phương tiện ${_currentPhuongTien.tenPhuongTien} (${_currentPhuongTien.bienSo}) khỏi hệ thống?',
    );

    if (confirm == true && mounted) {
      final success = await context.read<PhuongTienViewModel>().removeItem(_currentPhuongTien.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa phương tiện thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<PhuongTienViewModel>().error ?? 'Không thể xóa phương tiện'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedRegDate = _currentPhuongTien.ngayDangKy != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(_currentPhuongTien.ngayDangKy!.toLocal())
        : 'Chưa cập nhật';
    final formattedCancelDate = _currentPhuongTien.ngayHuy != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(_currentPhuongTien.ngayHuy!.toLocal())
        : 'Đang hoạt động';

    final bool isActive = _currentPhuongTien.trangThai == 1;
    final Color statusColor = isActive ? AppColors.tealPrimary : AppColors.red;

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
                    children: [
                      _buildHeaderCard(statusColor, isActive),
                      const SizedBox(height: 20),
                      _buildInfoSection('Chi tiết Phương tiện', [
                        _buildInfoRow(Icons.tag_rounded, 'Biển số xe', _currentPhuongTien.bienSo),
                        _buildInfoRow(Icons.category_rounded, 'Loại xe', _currentPhuongTien.tenLoaiPhuongTien),
                        _buildInfoRow(Icons.apartment_rounded, 'Căn hộ sở hữu', 'Căn ${_currentPhuongTien.soCanHo}'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin đăng ký', [
                        _buildInfoRow(Icons.calendar_today_rounded, 'Ngày đăng ký', formattedRegDate),
                        _buildInfoRow(Icons.cancel_presentation_rounded, 'Ngày hủy', formattedCancelDate),
                        _buildInfoRow(Icons.person_outline_rounded, 'Người cập nhật cuối', _currentPhuongTien.tenNguoiCapNhat.isNotEmpty ? _currentPhuongTien.tenNguoiCapNhat : 'Ban Quản Lý'),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
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
              'Chi tiết Phương tiện',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
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
              child: Icon(Icons.edit_rounded, size: 18, color: AppColors.tealPrimary),
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
              child: Icon(Icons.delete_rounded, size: 18, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color statusColor, bool isActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 37.5,
            backgroundColor: AppColors.borderSide,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: statusColor.withValues(alpha: 0.15),
              child: Icon(
                _currentPhuongTien.tenLoaiPhuongTien.toLowerCase().contains('ô tô') ||
                        _currentPhuongTien.tenLoaiPhuongTien.toLowerCase().contains('car')
                    ? Icons.directions_car_rounded
                    : Icons.motorcycle_rounded,
                color: statusColor,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentPhuongTien.tenPhuongTien,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isActive ? 'Đang hoạt động' : 'Đã hủy',
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.8),
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
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
