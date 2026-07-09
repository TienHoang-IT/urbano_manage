import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/features/thong_bao/ViewModels/thong_bao_viewmodel.dart';
import 'package:urbano_manage/features/thong_bao/Views/thong_bao_detail_view.dart';
import 'package:urbano_manage/features/thong_bao/Views/thong_bao_form_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThongBaoViewModel>();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.tealPrimary,
            backgroundColor: AppColors.bgMid,
            onRefresh: () => viewModel.fetchThongBaos(),
            child: _buildContent(viewModel),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'thong_bao_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThongBaoFormView()),
                ).then((value) {
                  if (value == true) {
                    context.read<ThongBaoViewModel>().fetchThongBaos();
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: viewModel.thongBaos.length,
      itemBuilder: (context, index) {
        final t = viewModel.thongBaos[index];
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt.toLocal());

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            tileColor: AppColors.nenContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderButton),
            ),
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
                      t.tenNguoiTao.isNotEmpty ? t.tenNguoiTao : 'Ban Quản Lý',
                      style: const TextStyle(color: AppColors.tealPrimary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.iconMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ThongBaoDetailView(thongBao: t)),
              ).then((value) {
                context.read<ThongBaoViewModel>().fetchThongBaos();
              });
            },
          ),
        );
      },
    );
  }
}
