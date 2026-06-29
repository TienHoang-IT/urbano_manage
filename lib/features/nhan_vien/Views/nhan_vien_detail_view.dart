import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';

class NhanVienDetailView extends StatelessWidget {
  final NhanVien nhanVien;

  const NhanVienDetailView({super.key, required this.nhanVien});

  String _getChucVuText(int chucVu) {
    switch (chucVu) {
      case 1:
        return 'Admin';
      case 2:
        return 'Kế toán';
      case 3:
        return 'Kỹ thuật';
      case 4:
        return 'Lễ tân';
      default:
        return 'Nhân viên';
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _getChucVuText(nhanVien.chucVu);
    final formattedDob = nhanVien.ngaySinh != null
        ? DateFormat('dd/MM/yyyy').format(nhanVien.ngaySinh!.toLocal())
        : 'Chưa cập nhật';
    final formattedHiredDate = nhanVien.ngayVaoLam != null
        ? DateFormat('dd/MM/yyyy').format(nhanVien.ngayVaoLam!.toLocal())
        : 'Chưa cập nhật';
    final formattedResignedDate = nhanVien.ngayNghiLam != null
        ? DateFormat('dd/MM/yyyy').format(nhanVien.ngayNghiLam!.toLocal())
        : 'Đang làm việc';

    final initial = nhanVien.hoTen.isNotEmpty ? nhanVien.hoTen[0].toUpperCase() : 'N';

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
                      _buildHeaderCard(initial, role),
                      const SizedBox(height: 20),
                      _buildInfoSection('Thông tin nhân viên', [
                        _buildInfoRow(Icons.badge_rounded, 'Mã nhân viên', nhanVien.maNhanVien),
                        _buildInfoRow(Icons.cake_rounded, 'Ngày sinh', formattedDob),
                        _buildInfoRow(Icons.perm_identity_rounded, 'Số CCCD', nhanVien.cccd.isNotEmpty ? nhanVien.cccd : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin liên hệ', [
                        _buildInfoRow(Icons.phone_rounded, 'Điện thoại', nhanVien.sdt.isNotEmpty ? nhanVien.sdt : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.email_rounded, 'Email', nhanVien.email.isNotEmpty ? nhanVien.email : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Công việc', [
                        _buildInfoRow(Icons.work_history_rounded, 'Ngày vào làm', formattedHiredDate),
                        _buildInfoRow(Icons.work_off_rounded, 'Ngày nghỉ làm', formattedResignedDate),
                        _buildInfoRow(Icons.notes_rounded, 'Ghi chú', nhanVien.ghiChu.isNotEmpty ? nhanVien.ghiChu : 'Không có ghi chú'),
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
              'Chi tiết Nhân viên',
              style: TextStyle(
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

  Widget _buildHeaderCard(String initial, String role) {
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
                  nhanVien.hoTen,
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
                    role,
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
