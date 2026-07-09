import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/phuong_tien_model.dart';
import 'package:urbano_manage/features/phuong_tien/ViewModels/phuong_tien_viewmodel.dart';
import 'package:urbano_manage/features/phuong_tien/Views/phuong_tien_detail_view.dart';
import 'package:urbano_manage/features/phuong_tien/Views/phuong_tien_form_view.dart';

class PhuongTienListView extends StatefulWidget {
  const PhuongTienListView({super.key});

  @override
  State<PhuongTienListView> createState() => _PhuongTienListViewState();
}

class _PhuongTienListViewState extends State<PhuongTienListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhuongTienViewModel>().fetchItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhuongTienViewModel>();
    final filteredList = viewModel.items.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.tenPhuongTien.toLowerCase().contains(query) ||
          p.bienSo.toLowerCase().contains(query) ||
          p.soCanHo.toLowerCase().contains(query) ||
          p.tenLoaiPhuongTien.toLowerCase().contains(query);
    }).toList();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Column(
            children: [
              _buildSearchBox(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.tealPrimary,
                  backgroundColor: AppColors.bgMid,
                  onRefresh: () => viewModel.fetchItems(),
                  child: _buildContent(viewModel, filteredList),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'phuong_tien_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhuongTienFormView()),
                ).then((value) {
                  if (value == true) {
                    context.read<PhuongTienViewModel>().fetchItems();
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

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm phương tiện (Biển số, Tên, Căn hộ)...',
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.iconMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.iconMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderButton),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.tealPrimary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderButton),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PhuongTienViewModel viewModel, List<PhuongTien> filteredList) {
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
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary),
              onPressed: () => viewModel.fetchItems(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy phương tiện nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final pt = filteredList[index];
        final bool isActive = pt.trangThai == 1;
        final Color statusColor = isActive ? AppColors.tealPrimary : AppColors.red;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            tileColor: AppColors.nenContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderButton),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: statusColor.withValues(alpha: 0.1),
              child: Icon(
                pt.tenLoaiPhuongTien.toLowerCase().contains('ô tô') ||
                        pt.tenLoaiPhuongTien.toLowerCase().contains('car')
                    ? Icons.directions_car_rounded
                    : Icons.motorcycle_rounded,
                color: statusColor,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pt.tenPhuongTien,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isActive ? 'Hoạt động' : 'Đã hủy',
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.tag_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text('Biển số: ${pt.bienSo}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.apartment_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 4),
                    Text('Căn hộ: ${pt.soCanHo}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text('Loại xe: ${pt.tenLoaiPhuongTien}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.iconMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhuongTienDetailView(phuongTien: pt)),
              ).then((value) {
                context.read<PhuongTienViewModel>().fetchItems();
              });
            },
          ),
        );
      },
    );
  }
}
