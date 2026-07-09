import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/features/hoa_don/Views/hoa_don_detail_view.dart';
import 'package:urbano_manage/features/hoa_don/Views/hoa_don_form_view.dart';

class HoaDonListView extends StatefulWidget {
  const HoaDonListView({super.key});

  @override
  State<HoaDonListView> createState() => _HoaDonListViewState();
}

class _HoaDonListViewState extends State<HoaDonListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HoaDonViewModel>().fetchHoaDons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HoaDonViewModel>();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabs(viewModel),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.tealPrimary,
                  backgroundColor: AppColors.bgMid,
                  onRefresh: () => viewModel.fetchHoaDons(),
                  child: _buildContent(viewModel),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'hoa_don_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HoaDonFormView()),
                ).then((value) {
                  if (value == true) {
                    context.read<HoaDonViewModel>().fetchHoaDons();
                  }
                });
              },
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(HoaDonViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabChip('Tất cả', 0, viewModel),
          const SizedBox(width: 8),
          _tabChip('Chưa trả', 1, viewModel),
          const SizedBox(width: 8),
          _tabChip('Đã trả', 2, viewModel),
          const SizedBox(width: 8),
          _tabChip('Trả một phần', 3, viewModel),
          const SizedBox(width: 8),
          _tabChip('Quá hạn', 4, viewModel),
        ],
      ),
    );
  }

  Widget _tabChip(String label, int index, HoaDonViewModel viewModel) {
    final selected = viewModel.currentTab == index;
    return GestureDetector(
      onTap: () => viewModel.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? AppColors.tealPrimary.withValues(alpha: 0.15)
              : AppColors.nenContainer,
          border: Border.all(
            color: selected ? AppColors.borderSide : AppColors.borderButton,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.tealPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HoaDonViewModel viewModel) {
    if (viewModel.isLoading && viewModel.hoaDons.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.hoaDons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.error!,
              style: const TextStyle(color: AppColors.red, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary),
              onPressed: () => viewModel.fetchHoaDons(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (viewModel.hoaDons.isEmpty) {
      return const Center(
        child: Text(
          'Không có hóa đơn nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: viewModel.hoaDons.length,
      itemBuilder: (context, index) {
        final h = viewModel.hoaDons[index];

        Color statusColor;
        switch (h.displayTrangThai) {
          case 1:
            statusColor = AppColors.red;
            break;
          case 2:
            statusColor = AppColors.amber;
            break;
          case 3:
            statusColor = AppColors.tealPrimary;
            break;
          case 4:
            statusColor = AppColors.red;
            break;
          default:
            statusColor = AppColors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            tileColor: AppColors.nenContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderButton),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  h.maThanhToan,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  currencyFormat.format(h.tongTien),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Căn hộ: ${h.soCanHo.isNotEmpty ? h.soCanHo : h.canHo}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text('Kỳ hóa đơn: T${h.thang}/${h.nam}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trạng thái:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        h.trangThaiText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.iconMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HoaDonDetailView(hoaDon: h)),
              ).then((value) {
                context.read<HoaDonViewModel>().fetchHoaDons();
              });
            },
          ),
        );
      },
    );
  }
}
