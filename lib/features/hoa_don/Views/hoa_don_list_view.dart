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
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: 'hoa_don_add_fab',
              backgroundColor: AppColors.tealPrimary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(HoaDonViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _tabChip('Tất cả', 0, viewModel),
          const SizedBox(width: 10),
          _tabChip('Chưa trả', 1, viewModel),
          const SizedBox(width: 10),
          _tabChip('Đã trả', 2, viewModel),
          const SizedBox(width: 10),
          _tabChip('Trả một phần', 3, viewModel),
          const SizedBox(width: 10),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              onPressed: () => viewModel.fetchHoaDons(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (viewModel.hoaDons.isEmpty) {
      return const Center(
        child: Text(
          'Không có hóa đơn nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100), // extra padding for FAB
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

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HoaDonDetailView(hoaDon: h)),
            ).then((value) {
              context.read<HoaDonViewModel>().fetchHoaDons();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.nenContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h.maThanhToan,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w600, 
                        fontSize: 16, 
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        h.trangThaiText,
                        style: TextStyle(
                          color: statusColor, 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.apartment_rounded, color: AppColors.iconMuted, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Căn hộ: ${h.soCanHo.isNotEmpty ? h.soCanHo : h.canHo}', 
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_view_month_rounded, color: AppColors.iconMuted, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Kỳ: T${h.thang}/${h.nam}', 
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(h.tongTien),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w700, 
                        fontSize: 18, 
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
