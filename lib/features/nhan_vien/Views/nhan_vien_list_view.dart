import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';
import 'package:urbano_manage/features/nhan_vien/ViewModels/nhan_vien_viewmodel.dart';
import 'package:urbano_manage/features/nhan_vien/Views/nhan_vien_detail_view.dart';

class NhanVienListView extends StatefulWidget {
  const NhanVienListView({super.key});

  @override
  State<NhanVienListView> createState() => _NhanVienListViewState();
}

class _NhanVienListViewState extends State<NhanVienListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NhanVienViewModel>().fetchNhanViens();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getChucVuText(int chucVu) {
    switch (chucVu) {
      case 1:
        return 'Admin';
      case 2:
        return 'Kế toán';
      case 3:
        return 'Kỹ thuật';
      case 4:
        return 'Lễ tân';
      default:
        return 'Nhân viên';
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NhanVienViewModel>();
    final filteredList = viewModel.nhanViens.where((n) {
      final query = _searchQuery.toLowerCase();
      return n.hoTen.toLowerCase().contains(query) ||
          n.maNhanVien.toLowerCase().contains(query) ||
          n.sdt.contains(query) ||
          n.email.toLowerCase().contains(query);
    }).toList();

    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          _buildSearchBox(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.tealPrimary,
              backgroundColor: AppColors.bgMid,
              onRefresh: () => viewModel.fetchNhanViens(),
              child: _buildContent(viewModel, filteredList),
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
          hintText: 'Tìm kiếm nhân viên (Tên, Mã NV, SĐT)...',
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

  Widget _buildContent(NhanVienViewModel viewModel, List<NhanVien> filteredList) {
    if (viewModel.isLoading && viewModel.nhanViens.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.nhanViens.isEmpty) {
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
              onPressed: () => viewModel.fetchNhanViens(),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy nhân viên nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final nv = filteredList[index];
        final initial = nv.hoTen.isNotEmpty ? nv.hoTen[0].toUpperCase() : 'N';
        final role = _getChucVuText(nv.chucVu);

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nv.hoTen,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSide),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(color: AppColors.tealPrimary, fontSize: 10, fontWeight: FontWeight.bold),
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
                    const Icon(Icons.badge_outlined, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text('Mã NV: ${nv.maNhanVien}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 12, color: AppColors.iconMuted),
                    const SizedBox(width: 6),
                    Text(nv.sdt.isNotEmpty ? nv.sdt : 'Chưa cập nhật SĐT',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.iconMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NhanVienDetailView(nhanVien: nv)),
              );
            },
          ),
        );
      },
    );
  }
}
