import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';

class BatchResultDialog extends StatelessWidget {
  final Map<String, dynamic> result;

  const BatchResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final int createdCount = (result['createdCount'] as num? ?? result['soLuongTaoMoi'] as num? ?? 0).toInt();
    final int skippedCount = (result['skippedCount'] as num? ?? result['soLuongBoQua'] as num? ?? 0).toInt();
    final double totalAmount = (result['totalAmount'] as num? ?? result['tongTienPhatHanh'] as num? ?? 0.0).toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSide, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded, color: AppColors.tealPrimary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KẾT QUẢ PHÁT HÀNH HÀNG LOẠT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hoàn tất xử lý hóa đơn định kỳ',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Column(
                children: [
                  _buildResultRow(
                    icon: Icons.add_task_rounded,
                    label: 'Tạo mới thành công',
                    value: '$createdCount hóa đơn',
                    color: AppColors.tealPrimary,
                  ),
                  const Divider(height: 20, color: Colors.white10),
                  _buildResultRow(
                    icon: Icons.replay_circle_filled_rounded,
                    label: 'Bỏ qua (đã có hóa đơn)',
                    value: '$skippedCount căn hộ',
                    color: AppColors.amber,
                  ),
                  const Divider(height: 20, color: Colors.white10),
                  _buildResultRow(
                    icon: Icons.payments_rounded,
                    label: 'Tổng tiền phát hành',
                    value: currencyFormatter.format(totalAmount),
                    color: AppColors.textPrimary,
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'XEM DANH SÁCH HÓA ĐƠN',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
