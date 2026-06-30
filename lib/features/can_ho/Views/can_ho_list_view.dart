import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/features/can_ho/Views/can_ho_detail_view.dart';
import 'package:urbano_manage/features/can_ho/Views/can_ho_form_view.dart';

class CanHoListView extends StatefulWidget {
  const CanHoListView({super.key});

  @override
  State<CanHoListView> createState() => _CanHoListViewState();
}

class _CanHoListViewState extends State<CanHoListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CanHoViewModel>().fetchCanHos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CanHoViewModel>();
    final filteredList = viewModel.canHos.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.soCanHo.toLowerCase().contains(query) ||
          c.tenToaNha.toLowerCase().contains(query) ||
          c.tenLoaiCanHo.toLowerCase().contains(query);
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
                  onRefresh: () => viewModel.fetchCanHos(),
                  child: _buildContent(viewModel, filteredList),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'can_ho_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CanHoFormView()),
                ).then((value) {
                  if (value == true) {
                    context.read<CanHoViewModel>().fetchCanHos();
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
          hintText: 'Tìm kiếm căn hộ (Số căn, Tòa nhà, Loại)...',
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

  Widget _buildContent(CanHoViewModel viewModel, List<CanHo> filteredList) {
    if (viewModel.isLoading && viewModel.canHos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.canHos.isEmpty) {
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
              onPressed: () => viewModel.fetchCanHos(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy căn hộ nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final ch = filteredList[index];

        Color statusColor;
        switch (ch.trangThaiId) {
          case 1:
            statusColor = AppColors.tealPrimary;
            break;
          case 2:
            statusColor = AppColors.blue;
            break;
          case 3:
            statusColor = AppColors.amber;
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: statusColor.withValues(alpha: 0.1),
              child: Icon(Icons.apartment_rounded, color: statusColor),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Căn hộ ${ch.soCanHo}',
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
                    ch.tenTrangThai.isNotEmpty ? ch.tenTrangThai : 'Chưa rõ',
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
                    const Icon(Icons.business_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text('Tòa nhà: ${ch.tenToaNha}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.layers_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 4),
                    Text('Tầng: ${ch.tang}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text('Loại: ${ch.tenLoaiCanHo}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.iconMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CanHoDetailView(canHo: ch)),
              ).then((value) {
                context.read<CanHoViewModel>().fetchCanHos();
              });
            },
          ),
        );
      },
    );
  }
}
