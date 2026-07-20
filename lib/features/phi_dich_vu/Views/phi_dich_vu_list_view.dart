import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/phi_dich_vu_model.dart';
import 'package:urbano_manage/features/phi_dich_vu/ViewModels/phi_dich_vu_viewmodel.dart';
import 'package:urbano_manage/features/phi_dich_vu/Views/phi_dich_vu_detail_view.dart';
import 'package:urbano_manage/features/phi_dich_vu/Views/phi_dich_vu_form_view.dart';

class PhiDichVuListView extends StatefulWidget {
  const PhiDichVuListView({super.key});

  @override
  State<PhiDichVuListView> createState() => _PhiDichVuListViewState();
}

class _PhiDichVuListViewState extends State<PhiDichVuListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhiDichVuViewModel>().fetchPhiDichVus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhiDichVuViewModel>();
    final filteredList = viewModel.phiDichVus.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.tenPhiDichVu.toLowerCase().contains(query) ||
          p.tenLoaiPhiDichVu.toLowerCase().contains(query);
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
                  onRefresh: () => viewModel.fetchPhiDichVus(),
                  child: _buildContent(viewModel, filteredList),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'phi_dich_vu_add_fab',
              backgroundColor: AppColors.tealPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhiDichVuFormView()),
                ).then((value) {
                  if (value == true) {
                    context.read<PhiDichVuViewModel>().fetchPhiDichVus();
                  }
                });
              },
              child: Icon(Icons.add_rounded, color: AppColors.textPrimary),
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
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm phí dịch vụ...',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.iconMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppColors.iconMuted),
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
            borderSide: BorderSide(color: AppColors.borderButton),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.tealPrimary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderButton),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PhiDichVuViewModel viewModel, List<PhiDichVu> filteredList) {
    if (viewModel.isLoading && viewModel.phiDichVus.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.phiDichVus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.error!,
              style: TextStyle(color: AppColors.red, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary),
              onPressed: () => viewModel.fetchPhiDichVus(),
              child: Text('Thử lại', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      );
    }

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy phí dịch vụ nào',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final p = filteredList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            tileColor: AppColors.nenContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.borderButton),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.tealPrimary.withValues(alpha: 0.1),
              child: Icon(Icons.room_service_rounded, color: AppColors.tealPrimary),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.tenPhiDichVu,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  currencyFormat.format(p.donGia),
                  style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Loại: ${p.tenLoaiPhiDichVu}', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text('Đơn vị: ${p.tenDonViTinh}', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Cách tính: ${p.tenLoaiTinhPhi}', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.iconMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhiDichVuDetailView(phiDichVu: p)),
              ).then((value) {
                context.read<PhiDichVuViewModel>().fetchPhiDichVus();
              });
            },
          ),
        );
      },
    );
  }
}
