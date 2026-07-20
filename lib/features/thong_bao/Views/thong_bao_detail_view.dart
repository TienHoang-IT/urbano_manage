import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/Models/thong_bao_model.dart';
import 'package:urbano_manage/features/thong_bao/ViewModels/thong_bao_viewmodel.dart';
import 'package:urbano_manage/features/thong_bao/Views/thong_bao_form_view.dart';

class ThongBaoDetailView extends StatefulWidget {
  final ThongBao thongBao;

  const ThongBaoDetailView({super.key, required this.thongBao});

  @override
  State<ThongBaoDetailView> createState() => _ThongBaoDetailViewState();
}

class _ThongBaoDetailViewState extends State<ThongBaoDetailView> {
  late ThongBao _currentThongBao;

  @override
  void initState() {
    super.initState();
    _currentThongBao = widget.thongBao;
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ThongBaoFormView(thongBao: _currentThongBao)),
    );

    if (result == true && mounted) {
      final vm = context.read<ThongBaoViewModel>();
      final updated = vm.thongBaos.firstWhere(
        (t) => t.id == _currentThongBao.id,
        orElse: () => _currentThongBao,
      );
      setState(() {
        _currentThongBao = updated;
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa thông báo "${_currentThongBao.tieuDe}" khỏi hệ thống?',
    );

    if (confirm == true && mounted) {
      final success = await context.read<ThongBaoViewModel>().removeThongBao(_currentThongBao.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa thông báo thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<ThongBaoViewModel>().error ?? 'Không thể xóa thông báo'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(_currentThongBao.createdAt.toLocal());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppbar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.nenContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentThongBao.tieuDe,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.person_outline_rounded, size: 14, color: AppColors.tealPrimary),
                                const SizedBox(width: 6),
                                Text(
                                  _currentThongBao.tenNguoiTao.isNotEmpty ? _currentThongBao.tenNguoiTao : 'Ban Quản Lý',
                                  style: TextStyle(color: AppColors.tealPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time_rounded, size: 14, color: AppColors.iconMuted),
                                const SizedBox(width: 6),
                                Text(
                                  formattedDate,
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'NỘI DUNG CHI TIẾT',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.tealPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.nenContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: Text(
                          _currentThongBao.noiDung,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Chi tiết Thông báo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToEdit(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.edit_rounded, size: 18, color: AppColors.tealPrimary),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.delete_rounded, size: 18, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
