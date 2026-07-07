import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/Models/yeu_cau_cu_dan_model.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/ViewModels/yeu_cau_cu_dan_viewmodel.dart';
import 'package:urbano_manage/features/nhan_vien/ViewModels/nhan_vien_viewmodel.dart';

class YeuCauCuDanDetailView extends StatefulWidget {
  final YeuCauCuDan yeuCau;

  const YeuCauCuDanDetailView({super.key, required this.yeuCau});

  @override
  State<YeuCauCuDanDetailView> createState() => _YeuCauCuDanDetailViewState();
}

class _YeuCauCuDanDetailViewState extends State<YeuCauCuDanDetailView> {
  int? _currentLoggedInStaffId;
  int? _assignedStaffId;

  @override
  void initState() {
    super.initState();
    _assignedStaffId = widget.yeuCau.nhanVienXuLy;
    _loadLoggedInStaff();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NhanVienViewModel>().fetchNhanViens();
    });
  }

  Future<void> _loadLoggedInStaff() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nvStr = prefs.getString('nhanVien');
      if (nvStr != null) {
        final nvMap = jsonDecode(nvStr) as Map<String, dynamic>;
        setState(() {
          _currentLoggedInStaffId = nvMap['id'] as int?;
        });
      }
    } catch (e) {
      debugPrint('Error loading logged in staff ID: $e');
    }
  }

  Future<void> _updateAssignment(int? newStaffId) async {
    if (newStaffId == null) return;
    final viewModel = context.read<YeuCauCuDanViewModel>();
    
    // We keep the request state, but update the staff handler
    final success = await viewModel.updateRequestStatus(
      widget.yeuCau.id,
      widget.yeuCau.trangThai,
      newStaffId,
    );

    if (success && mounted) {
      setState(() {
        _assignedStaffId = newStaffId;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã phân công lại nhân viên xử lý thành công'),
          backgroundColor: AppColors.tealPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );

    final viewModel = context.watch<YeuCauCuDanViewModel>();
    final employeeViewModel = context.watch<NhanVienViewModel>();
    
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(widget.yeuCau.ngayGui.toLocal());
    final formattedCompleteDate = widget.yeuCau.ngayHoanThanh != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(widget.yeuCau.ngayHoanThanh!.toLocal())
        : null;

    Color priorityColor;
    switch (widget.yeuCau.mucDoUuTien) {
      case 3:
        priorityColor = AppColors.red;
        break;
      case 2:
        priorityColor = AppColors.amber;
        break;
      default:
        priorityColor = AppColors.tealPrimary;
    }

    Color statusColor;
    switch (widget.yeuCau.trangThai) {
      case 1:
        statusColor = AppColors.blue;
        break;
      case 2:
        statusColor = AppColors.amber;
        break;
      case 3:
        statusColor = AppColors.tealPrimary;
        break;
      default:
        statusColor = AppColors.red;
    }

    // Lookup currently assigned employee's name
    String assignedStaffName = 'Chưa phân công';
    if (_assignedStaffId != null) {
      final staff = employeeViewModel.nhanViens.firstWhere(
        (n) => n.id == _assignedStaffId,
        orElse: () => NhanVien(
          id: _assignedStaffId!,
          hoTen: widget.yeuCau.tenNhanVienXuLy.isNotEmpty ? widget.yeuCau.tenNhanVienXuLy : 'Nhân viên ID: $_assignedStaffId',
          maNhanVien: '',
          chucVu: 3,
          sdt: '',
          email: '',
          cccd: '',
          ghiChu: '',
          trangThai: 1,
        ),
      );
      assignedStaffName = staff.hoTen;
    }

    final activeRequest = widget.yeuCau.trangThai == 1 || widget.yeuCau.trangThai == 2;

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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Request Title Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.nenContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    widget.yeuCau.trangThaiText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'Độ ưu tiên: ${widget.yeuCau.mucDoUuTienText}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: priorityColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.yeuCau.tieuDe,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.category_outlined, size: 14, color: AppColors.tealPrimary),
                                const SizedBox(width: 6),
                                Text(
                                  widget.yeuCau.tenLoaiYeuCau,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.tealPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content Section
                      const Text(
                        'Nội dung yêu cầu',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.nenContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: Text(
                          widget.yeuCau.noiDung,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Information details
                      const Text(
                        'Thông tin liên quan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.nenContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Người gửi', widget.yeuCau.tenCuDan, Icons.person_outline),
                            const Divider(color: AppColors.borderButton, height: 24),
                            _buildDetailRow('Ngày gửi', formattedDate, Icons.access_time_rounded),
                            const Divider(color: AppColors.borderButton, height: 24),
                            _buildDetailRow('Nhân viên xử lý', assignedStaffName, Icons.badge_outlined),
                            if (formattedCompleteDate != null) ...[
                              const Divider(color: AppColors.borderButton, height: 24),
                              _buildDetailRow('Ngày hoàn thành', formattedCompleteDate, Icons.check_circle_outline),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Staff Assignment Selector
                      if (activeRequest) ...[
                        const Text(
                          'Phân công nhân viên xử lý',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.nenContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderButton),
                          ),
                          child: employeeViewModel.isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary))
                              : AppDropdownField<int>(
                                  value: _assignedStaffId,
                                  hint: 'Chọn nhân viên xử lý',
                                  prefixIcon: Icons.badge_outlined,
                                  onChanged: _updateAssignment,
                                  items: employeeViewModel.nhanViens
                                      .map((e) => DropdownMenuItem<int>(
                                            value: e.id,
                                            child: Text('${e.hoTen} (${_getChucVuText(e.chucVu)})'),
                                          ))
                                      .toList(),
                                ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Action Buttons
                      if (viewModel.isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: AppColors.tealPrimary),
                        )
                      else
                        _buildActionButtons(context, viewModel),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa yêu cầu "${widget.yeuCau.tieuDe}"?',
    );

    if (confirm == true && mounted) {
      final success = await context.read<YeuCauCuDanViewModel>().removeYeuCau(widget.yeuCau.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa yêu cầu thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<YeuCauCuDanViewModel>().error ?? 'Không thể xóa yêu cầu'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Widget _buildAppbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _buildButtonBack(context),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Chi tiết Yêu cầu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
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

  Widget _buildButtonBack(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, true), // Return true to refresh list if needed
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.iconMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, YeuCauCuDanViewModel viewModel) {
    final currentStaffId = _currentLoggedInStaffId ?? 1;

    if (widget.yeuCau.trangThai == 1) {
      // Pending -> Option to process
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tealPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            final ok = await viewModel.updateRequestStatus(widget.yeuCau.id, 2, currentStaffId);
            if (ok && mounted) {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context, true);
              messenger.showSnackBar(
                const SnackBar(content: Text('Đã nhận xử lý yêu cầu này')),
              );
            }
          },
          child: const Text(
            'Nhận xử lý',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else if (widget.yeuCau.trangThai == 2) {
      // In Progress -> Option to complete or reject
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final ok = await viewModel.updateRequestStatus(widget.yeuCau.id, 4, currentStaffId);
                  if (ok && mounted) {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context, true);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Đã từ chối yêu cầu này')),
                    );
                  }
                },
                child: const Text(
                  'Từ chối',
                  style: TextStyle(color: AppColors.red, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final ok = await viewModel.updateRequestStatus(widget.yeuCau.id, 3, currentStaffId);
                  if (ok && mounted) {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context, true);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Đã hoàn thành xử lý yêu cầu')),
                    );
                  }
                },
                child: const Text(
                  'Hoàn thành',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
