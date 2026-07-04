import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/features/tien_ich/ViewModels/tien_ich_viewmodel.dart';
import 'package:urbano_manage/features/tien_ich/Views/tien_ich_form_view.dart';
import 'package:urbano_manage/features/tien_ich/Views/tien_ich_detail_view.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';

class TienIchListView extends StatefulWidget {
  const TienIchListView({super.key});

  @override
  State<TienIchListView> createState() => _TienIchListViewState();
}

class _TienIchListViewState extends State<TienIchListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TienIchViewModel>().fetchTienIchs();
    });
  }

  void _onSearchChanged() {
    context.read<TienIchViewModel>().setSearchQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TienIchViewModel>();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppTextField(
                  controller: _searchController,
                  hint: 'Tìm kiếm tiện ích theo tên...',
                  prefixIcon: Icons.search_rounded,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.tealPrimary,
                  backgroundColor: AppColors.bgMid,
                  onRefresh: () => viewModel.fetchTienIchs(),
                  child: _buildContent(viewModel),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'tien_ich_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () async {
                final vm = context.read<TienIchViewModel>();
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
                      MaterialPageRoute(builder: (_) => const TienIchFormView()),
                    ).then((value) {
                      if (value == true) {
                        context.read<TienIchViewModel>().fetchTienIchs();
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

  Widget _buildContent(TienIchViewModel viewModel) {
    if (viewModel.isLoading && viewModel.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.items.isEmpty) {
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
              onPressed: () => viewModel.fetchTienIchs(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final list = viewModel.filteredItems;

    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy tiện ích nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildTienIchCard(list[index]);
      },
    );
  }

  Widget _buildTienIchCard(TienIch item) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final feeText = item.phiSuDung == 0 ? 'Miễn phí' : currencyFormatter.format(item.phiSuDung);

    Color statusColor;
    switch (item.trangThai) {
      case 1:
        statusColor = AppColors.tealPrimary;
        break;
      case 2:
        statusColor = AppColors.amber;
        break;
      default:
        statusColor = AppColors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TienIchDetailView(id: item.id),
              ),
            ).then((value) {
              if (value == true) {
                context.read<TienIchViewModel>().fetchTienIchs();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderButton),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.hinhUrl.isNotEmpty)
                  Image.network(
                    item.hinhUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  )
                else
                  _buildImagePlaceholder(),
                Padding(
                  padding: const EdgeInsets.all(16),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                      Text(
                        item.tenLoaiTienIch,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.tealPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.iconMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.toaNhaId != null
                                  ? '${item.viTri} - ${item.tenToaNha}'
                                  : item.viTri,
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.iconMuted),
                              const SizedBox(width: 6),
                              Text(
                                feeText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (item.canDatTruoc)
                            Row(
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.tealPrimary.withValues(alpha: 0.8)),
                                const SizedBox(width: 4),
                                const Text(
                                  'Cần đặt trước',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.bgMid,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 40,
          color: AppColors.iconMuted,
        ),
      ),
    );
  }
}
