import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/bang_tin_model.dart';
import 'package:urbano_manage/features/bang_tin/ViewModels/bang_tin_viewmodel.dart';
import 'package:urbano_manage/features/bang_tin/Views/bang_tin_detail_view.dart';
import 'package:urbano_manage/features/bang_tin/Views/bang_tin_form_view.dart';

class BangTinListView extends StatefulWidget {
  const BangTinListView({super.key});

  @override
  State<BangTinListView> createState() => _BangTinListViewState();
}

class _BangTinListViewState extends State<BangTinListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BangTinViewModel>().fetchItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BangTinViewModel>();
    final filteredList = viewModel.items.where((b) {
      final query = _searchQuery.toLowerCase();
      return b.tieuDe.toLowerCase().contains(query) ||
          b.noiDung.toLowerCase().contains(query) ||
          b.tenNguoiTao.toLowerCase().contains(query);
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
              heroTag: 'bang_tin_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BangTinFormView()),
                ).then((value) {
                  if (value == true) {
                    context.read<BangTinViewModel>().fetchItems();
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
          hintText: 'Tìm kiếm bảng tin...',
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

  Widget _buildContent(BangTinViewModel viewModel, List<BangTin> filteredList) {
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
          'Không có bài đăng bảng tin nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt.toLocal());

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            tileColor: AppColors.nenContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderButton),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: item.hinhUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.hinhUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholderIcon(),
                    ),
                  )
                : _buildPlaceholderIcon(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.tieuDe,
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
                  item.noiDung,
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
                      item.tenNguoiTao.isNotEmpty ? item.tenNguoiTao : 'Ban Quản Lý',
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
                MaterialPageRoute(builder: (_) => BangTinDetailView(bangTin: item)),
              ).then((value) {
                context.read<BangTinViewModel>().fetchItems();
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.tealPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.newspaper_rounded, color: AppColors.tealPrimary, size: 24),
    );
  }
}
