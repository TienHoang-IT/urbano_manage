import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';

class HoaDonDetailView extends StatelessWidget {
  final HoaDon hoaDon;

  const HoaDonDetailView({super.key, required this.hoaDon});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedDueDate = hoaDon.hanThanhToan != null
        ? DateFormat('dd/MM/yyyy').format(hoaDon.hanThanhToan!.toLocal())
        : 'Chưa cập nhật';
    final formattedCreatedAt = DateFormat('dd/MM/yyyy HH:mm').format(hoaDon.createdAt.toLocal());
    final statusColor = hoaDon.trangThai == 1
        ? AppColors.red
        : (hoaDon.trangThai == 2 ? AppColors.tealPrimary : AppColors.amber);

    final conThieu = hoaDon.tongTien - hoaDon.soTienDaThanhToan;

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
                      _buildInfoSection('Chi tiết hóa đơn', [
                        _buildInfoRow(Icons.apartment_rounded, 'Căn hộ ID', hoaDon.canHo.toString()),
                        _buildInfoRow(Icons.calendar_view_month_rounded, 'Kỳ hóa đơn', 'Tháng ${hoaDon.thang}/${hoaDon.nam}'),
                        _buildInfoRow(Icons.timer_rounded, 'Hạn thanh toán', formattedDueDate),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin thanh toán', [
                        _buildInfoRow(Icons.price_change_rounded, 'Chi phí dịch vụ', currencyFormat.format(hoaDon.chiPhi)),
                        _buildInfoRow(Icons.payment_rounded, 'Đã thanh toán', currencyFormat.format(hoaDon.soTienDaThanhToan)),
                        _buildInfoRow(Icons.money_off_rounded, 'Còn thiếu', currencyFormat.format(conThieu < 0 ? 0.0 : conThieu)),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin cập nhật', [
                        _buildInfoRow(Icons.person_outline_rounded, 'Người cập nhật', hoaDon.tenNguoiCapNhat.isNotEmpty ? hoaDon.tenNguoiCapNhat : 'N/A'),
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
              'Chi tiết Hóa đơn',
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
                hoaDon.maThanhToan,
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
                  hoaDon.trangThaiText,
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
            currencyFormat.format(hoaDon.tongTien),
            style: TextStyle(color: statusColor, fontSize: 32, fontWeight: FontWeight.bold),
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
