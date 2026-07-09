import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/ViewModels/dat_lich_tien_ich_viewmodel.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/Views/dat_lich_form_view.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/Views/dat_lich_detail_view.dart';

class DatLichListView extends StatefulWidget {
  const DatLichListView({super.key});

  @override
  State<DatLichListView> createState() => _DatLichListViewState();
}

class _DatLichListViewState extends State<DatLichListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatLichTienIchViewModel>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DatLichTienIchViewModel>();

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
                  onRefresh: () => viewModel.fetchBookings(),
                  child: _buildContent(viewModel),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'dat_lich_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () async {
                final vm = context.read<DatLichTienIchViewModel>();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: AppColors.tealPrimary),
                  ),
                );
                await vm.loadFormDropdowns();
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
                  if (vm.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vm.error!), backgroundColor: AppColors.red),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DatLichFormView()),
                    ).then((value) {
                      if (value == true) {
                        context.read<DatLichTienIchViewModel>().fetchBookings();
                      }
                    });
                  }
                }
              },
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(DatLichTienIchViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabChip('Tất cả', 0, viewModel),
          const SizedBox(width: 8),
          _tabChip('Chờ duyệt', 1, viewModel),
          const SizedBox(width: 8),
          _tabChip('Đã duyệt', 2, viewModel),
          const SizedBox(width: 8),
          _tabChip('Từ chối', 3, viewModel),
          const SizedBox(width: 8),
          _tabChip('Đã hủy', 4, viewModel),
          const SizedBox(width: 8),
          _tabChip('Hoàn thành', 5, viewModel),
        ],
      ),
    );
  }

  Widget _tabChip(String label, int index, DatLichTienIchViewModel viewModel) {
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

  Widget _buildContent(DatLichTienIchViewModel viewModel) {
    if (viewModel.isLoading && viewModel.bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.error!,
              style: const TextStyle(color: AppColors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary),
              onPressed: () => viewModel.fetchBookings(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (viewModel.bookings.isEmpty) {
      return const Center(
        child: Text(
          'Không có lịch đặt nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
      itemCount: viewModel.bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(viewModel.bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(DatLichTienIch item) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final timeStr = '${df.format(item.thoiGianBatDau.toLocal())} - ${df.format(item.thoiGianKetThuc.toLocal())}';

    Color statusColor;
    switch (item.trangThai) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DatLichDetailView(booking: item),
              ),
            ).then((value) {
              if (value == true) {
                context.read<DatLichTienIchViewModel>().fetchBookings();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderButton),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.tenTienIch,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        item.trangThaiText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 14, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Người đặt: ${item.tenCuDan}',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
                if (item.soCanHo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.apartment_rounded, size: 14, color: AppColors.iconMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Căn hộ: ${item.soCanHo}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        timeStr,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
                if (item.ghiChu.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ghi chú: ${item.ghiChu}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
