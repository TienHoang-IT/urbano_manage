import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/thong_bao_model.dart';
import 'package:urbano_manage/features/thong_bao/ViewModels/thong_bao_viewmodel.dart';

class ThongBaoListView extends StatefulWidget {
  const ThongBaoListView({super.key});

  @override
  State<ThongBaoListView> createState() => _ThongBaoListViewState();
}

class _ThongBaoListViewState extends State<ThongBaoListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThongBaoViewModel>().fetchThongBaos();
    });
  }

  void _showFullNotification(BuildContext context, ThongBao t) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt.toLocal());
        return AlertDialog(
          backgroundColor: AppColors.bgMid,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            t.tieuDe,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.tealPrimary),
                    const SizedBox(width: 6),
                    Text(
                      t.tenNguoiTao,
                      style: const TextStyle(color: AppColors.tealPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.borderButton, height: 1),
                const SizedBox(height: 16),
                Text(
                  t.noiDung,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Đóng', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThongBaoViewModel>();

    return RefreshIndicator(
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgMid,
      onRefresh: () => viewModel.fetchThongBaos(),
      child: _buildContent(viewModel),
    );
  }

  Widget _buildContent(ThongBaoViewModel viewModel) {
    if (viewModel.isLoading && viewModel.thongBaos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.thongBaos.isEmpty) {
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
              onPressed: () => viewModel.fetchThongBaos(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (viewModel.thongBaos.isEmpty) {
      return const Center(
        child: Text(
          'Không có thông báo nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: viewModel.thongBaos.length,
      itemBuilder: (context, index) {
        final t = viewModel.thongBaos[index];
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt.toLocal());

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderButton),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.tealPrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign_rounded, color: AppColors.tealPrimary, size: 20),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    t.tieuDe,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  t.noiDung,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.tealPrimary),
                    const SizedBox(width: 4),
                    Text(
                      t.tenNguoiTao,
                      style: const TextStyle(color: AppColors.tealPrimary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => _showFullNotification(context, t),
          ),
        );
      },
    );
  }
}
