import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/features/cu_dan/ViewModels/cu_dan_viewmodel.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_detail_view.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_form_view.dart';

class CuDanListView extends StatefulWidget {
  const CuDanListView({super.key});

  @override
  State<CuDanListView> createState() => _CuDanListViewState();
}

class _CuDanListViewState extends State<CuDanListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CuDanViewModel>().fetchCuDans();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CuDanViewModel>();
    final filteredList = viewModel.cuDans.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.hoTen.toLowerCase().contains(query) ||
          c.sdt.contains(query) ||
          c.email.toLowerCase().contains(query);
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
                  onRefresh: () => viewModel.fetchCuDans(),
                  child: _buildContent(viewModel, filteredList),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'cu_dan_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CuDanFormView()),
                );
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
          hintText: 'Tìm kiếm cư dân (Tên, SĐT, Email)...',
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

  Widget _buildContent(CuDanViewModel viewModel, List filteredList) {
    if (viewModel.isLoading && viewModel.cuDans.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.cuDans.isEmpty) {
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
              onPressed: () => viewModel.fetchCuDans(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy cư dân nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final c = filteredList[index];
        final initial = c.ten.isNotEmpty ? c.ten[0].toUpperCase() : 'C';

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
              backgroundColor: AppColors.tealPrimary.withValues(alpha: 0.1),
              child: Text(
                initial,
                style: const TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              c.hoTen,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text(c.sdt.isNotEmpty ? c.sdt : 'Chưa cập nhật SĐT',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.email_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        c.email.isNotEmpty ? c.email : 'Chưa cập nhật Email',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                MaterialPageRoute(builder: (_) => CuDanDetailView(cuDan: c)),
              );
            },
          ),
        );
      },
    );
  }
}
