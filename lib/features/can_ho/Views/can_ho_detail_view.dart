import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/features/can_ho/Views/can_ho_form_view.dart';

class CanHoDetailView extends StatefulWidget {
  final CanHo canHo;

  const CanHoDetailView({super.key, required this.canHo});

  @override
  State<CanHoDetailView> createState() => _CanHoDetailViewState();
}

class _CanHoDetailViewState extends State<CanHoDetailView> {
  late CanHo _currentCanHo;

  @override
  void initState() {
    super.initState();
    _currentCanHo = widget.canHo;
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CanHoFormView(canHo: _currentCanHo)),
    );

    if (result == true && mounted) {
      final vm = context.read<CanHoViewModel>();
      final updated = vm.canHos.firstWhere(
        (c) => c.id == _currentCanHo.id,
        orElse: () => _currentCanHo,
      );
      setState(() {
        _currentCanHo = updated;
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa căn hộ ${_currentCanHo.soCanHo} khỏi hệ thống?',
    );

    if (confirm == true && mounted) {
      final success = await context.read<CanHoViewModel>().removeCanHo(_currentCanHo.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa căn hộ thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<CanHoViewModel>().error ?? 'Không thể xóa căn hộ'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedPrice = _currentCanHo.gia != null ? currencyFormat.format(_currentCanHo.gia) : 'Chưa cập nhật';
    final formattedCreatedAt = DateFormat('dd/MM/yyyy HH:mm').format(_currentCanHo.createdAt.toLocal());
    final formattedUpdatedAt = DateFormat('dd/MM/yyyy HH:mm').format(_currentCanHo.updatedAt.toLocal());

    Color statusColor;
    switch (_currentCanHo.trangThaiId) {
      case 1: // Đang ở
        statusColor = AppColors.tealPrimary;
        break;
      case 2: // Trống
        statusColor = AppColors.blue;
        break;
      case 3: // Bảo trì
        statusColor = AppColors.amber;
        break;
      default:
        statusColor = AppColors.red;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                    children: [
                      _buildHeaderCard(statusColor),
                      const SizedBox(height: 20),
                      _buildInfoSection('Chi tiết Căn hộ', [
                        _buildInfoRow(Icons.business_rounded, 'Tòa nhà', _currentCanHo.tenToaNha),
                        _buildInfoRow(Icons.layers_rounded, 'Số tầng', 'Tầng ${_currentCanHo.tang}'),
                        _buildInfoRow(Icons.category_rounded, 'Loại căn hộ', _currentCanHo.tenLoaiCanHo),
                        _buildInfoRow(Icons.attach_money_rounded, 'Giá bán/thuê', formattedPrice),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin cập nhật', [
                        _buildInfoRow(Icons.person_outline_rounded, 'Người cập nhật', _currentCanHo.tenNguoiCapNhat.isNotEmpty ? _currentCanHo.tenNguoiCapNhat : 'Ban Quản Lý'),
                        _buildInfoRow(Icons.calendar_today_rounded, 'Ngày khởi tạo', formattedCreatedAt),
                        _buildInfoRow(Icons.edit_calendar_rounded, 'Cập nhật cuối', formattedUpdatedAt),
                      ]),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Chi tiết Căn hộ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
              child: const Icon(Icons.edit_rounded, size: 18, color: AppColors.tealPrimary),
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
              child: const Icon(Icons.delete_rounded, size: 18, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 37.5,
            backgroundColor: AppColors.borderSide,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.tealPrimary.withValues(alpha: 0.15),
              child: const Icon(Icons.apartment_rounded, color: AppColors.tealPrimary, size: 36),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Căn hộ ${_currentCanHo.soCanHo}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _currentCanHo.tenTrangThai.isNotEmpty ? _currentCanHo.tenTrangThai : 'Chưa cập nhật',
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String sectionTitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            sectionTitle,
            style: const TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.8),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderButton),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.iconMuted, size: 18),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
