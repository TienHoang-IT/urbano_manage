import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/features/lich_su_thanh_toan/ViewModels/lich_su_thanh_toan_viewmodel.dart';

class LichSuThanhToanListView extends StatefulWidget {
  const LichSuThanhToanListView({super.key});

  @override
  State<LichSuThanhToanListView> createState() => _LichSuThanhToanListViewState();
}

class _LichSuThanhToanListViewState extends State<LichSuThanhToanListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LichSuThanhToanViewModel>().fetchHistories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LichSuThanhToanViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.tealPrimary));
        }

        if (vm.error != null) {
          return Center(
            child: Text(
              'Lỗi: ${vm.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (vm.histories.isEmpty) {
          return Center(
            child: Text(
              'Không có dữ liệu lịch sử thanh toán',
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.tealPrimary,
          onRefresh: () => vm.fetchHistories(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bgDark),
                columns: [
                  DataColumn(label: Text('Mã Giao Dịch', style: TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Mã Hóa Đơn', style: TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Kỳ', style: TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Ngày Thanh Toán', style: TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Số Tiền', style: TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Phương Thức', style: TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Ghi Chú', style: TextStyle(color: AppColors.tealPrimary))),
                ],
                rows: vm.histories.map((h) {
                  return DataRow(cells: [
                    DataCell(Text(h.maGiaoDich, style: TextStyle(color: AppColors.textPrimary))),
                    DataCell(Text(h.maThanhToan, style: TextStyle(color: AppColors.textPrimary))),
                    DataCell(Text('${h.thang}/${h.nam}', style: TextStyle(color: AppColors.textPrimary))),
                    DataCell(Text(h.ngayThanhToan != null ? DateFormat('dd/MM/yyyy HH:mm').format(h.ngayThanhToan!.toLocal()) : '', style: TextStyle(color: AppColors.textPrimary))),
                    DataCell(Text(NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(h.soTien), style: const TextStyle(color: Colors.greenAccent))),
                    DataCell(Text(h.phuongThucThanhToan, style: TextStyle(color: AppColors.textPrimary))),
                    DataCell(Text(h.ghiChu, style: TextStyle(color: AppColors.textPrimary))),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
