import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/features/cu_dan/ViewModels/cu_dan_viewmodel.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_form_view.dart';

class CuDanDetailView extends StatelessWidget {
  final CuDan cuDan;

  const CuDanDetailView({super.key, required this.cuDan});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgMid,
          title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          content: Text('Bạn có chắc chắn muốn xóa cư dân ${cuDan.hoTen}?', style: const TextStyle(color: AppColors.textMuted)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Xóa'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                final success = await context.read<CuDanViewModel>().removeCuDan(cuDan.id);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xóa cư dân thành công')),
                    );
                    Navigator.of(context).pop(); // Back to list view
                  } else {
                    final err = context.read<CuDanViewModel>().error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err ?? 'Lỗi xảy ra khi xóa cư dân')),
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

  @override
  Widget build(BuildContext context) {
    final formattedDob = cuDan.ngaySinh != null
        ? DateFormat('dd/MM/yyyy').format(cuDan.ngaySinh!.toLocal())
        : 'Chưa cập nhật';
    final formattedCreatedAt = DateFormat('dd/MM/yyyy HH:mm').format(cuDan.createdAt.toLocal());

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 20),
                      _buildInfoSection('Thông tin cá nhân', [
                        _buildInfoRow(Icons.cake_rounded, 'Ngày sinh', formattedDob),
                        _buildInfoRow(Icons.wc_rounded, 'Giới tính', cuDan.gioiTinhText.isNotEmpty ? cuDan.gioiTinhText : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.badge_rounded, 'Số CCCD', cuDan.cccd.isNotEmpty ? cuDan.cccd : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin liên lạc', [
                        _buildInfoRow(Icons.phone_rounded, 'Điện thoại', cuDan.sdt.isNotEmpty ? cuDan.sdt : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.email_rounded, 'Email', cuDan.email.isNotEmpty ? cuDan.email : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Địa chỉ', [
                        _buildInfoRow(Icons.location_on_rounded, 'Địa chỉ đầy đủ', cuDan.diaChiDayDu.isNotEmpty ? cuDan.diaChiDayDu : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.map_rounded, 'Phường/Xã', cuDan.xa.isNotEmpty ? cuDan.xa : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.location_city_rounded, 'Tỉnh/Thành phố', cuDan.tinh.isNotEmpty ? cuDan.tinh : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Hệ thống', [
                        _buildInfoRow(Icons.calendar_today_rounded, 'Ngày tạo', formattedCreatedAt),
                        _buildInfoRow(Icons.check_circle_rounded, 'Trạng thái', cuDan.trangThaiText.isNotEmpty ? cuDan.trangThaiText : 'Hoạt động'),
                      ]),
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
          const Expanded(
            child: Text(
              'Chi tiết Cư dân',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.tealPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CuDanFormView(cuDan: cuDan)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final String initial = cuDan.ten.isNotEmpty ? cuDan.ten[0].toUpperCase() : 'C';
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
              backgroundColor: AppColors.tealPrimary.withValues(alpha: 0.15),
              child: Text(
                initial,
                style: const TextStyle(color: AppColors.tealPrimary, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cuDan.hoTen,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSide),
                  ),
                  child: Text(
                    cuDan.trangThaiText.isNotEmpty ? cuDan.trangThaiText : 'Hoạt động',
                    style: const TextStyle(color: AppColors.tealPrimary, fontSize: 11, fontWeight: FontWeight.bold),
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
}
