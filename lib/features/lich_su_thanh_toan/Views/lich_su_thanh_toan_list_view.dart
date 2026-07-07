import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/features/lich_su_thanh_toan/ViewModels/lich_su_thanh_toan_viewmodel.dart';

class LichSuThanhToanListView extends StatefulWidget {
  const LichSuThanhToanListView({Key? key}) : super(key: key);

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
          return const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary));
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
          return const Center(
            child: Text(
              'Không có dữ liệu lịch sử thanh toán',
              style: const TextStyle(color: AppColors.textMuted),
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
                headingRowColor: MaterialStateProperty.all(AppColors.bgDark),
                columns: const [
                  DataColumn(label: Text('Mã Giao Dịch', style: const TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Mã Hóa Đơn', style: const TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Kỳ', style: const TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Ngày Thanh Toán', style: const TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Số Tiền', style: const TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Phương Thức', style: const TextStyle(color: AppColors.tealPrimary))),
                  DataColumn(label: Text('Ghi Chú', style: const TextStyle(color: AppColors.tealPrimary))),
                ],
                rows: vm.histories.map((h) {
                  return DataRow(cells: [
                    DataCell(Text(h.maGiaoDich, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(h.maThanhToan, style: const TextStyle(color: Colors.white))),
                    DataCell(Text('${h.thang}/${h.nam}', style: const TextStyle(color: Colors.white))),
                    DataCell(Text(h.ngayThanhToan != null ? DateFormat('dd/MM/yyyy HH:mm').format(h.ngayThanhToan!.toLocal()) : '', style: const TextStyle(color: Colors.white))),
                    DataCell(Text(NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(h.soTien), style: const TextStyle(color: Colors.greenAccent))),
                    DataCell(Text(h.phuongThucThanhToan, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(h.ghiChu, style: const TextStyle(color: Colors.white))),
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
