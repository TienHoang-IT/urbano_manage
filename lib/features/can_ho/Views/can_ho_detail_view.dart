import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/features/can_ho/Views/can_ho_form_view.dart';
import 'package:urbano_manage/Models/cu_dan_can_ho_model.dart';
import 'package:urbano_manage/Services/cu_dan_can_ho_service.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_detail_view.dart';

class CanHoDetailView extends StatefulWidget {
  final CanHo canHo;

  const CanHoDetailView({super.key, required this.canHo});

  @override
  State<CanHoDetailView> createState() => _CanHoDetailViewState();
}

class _CanHoDetailViewState extends State<CanHoDetailView> {
  late CanHo _currentCanHo;
  final CuDanCanHoService _cuDanCanHoService = CuDanCanHoService();
  final CuDanService _cuDanService = CuDanService();
  List<CuDanCanHo> _residents = [];
  bool _isLoadingResidents = false;

  @override
  void initState() {
    super.initState();
    _currentCanHo = widget.canHo;
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    setState(() {
      _isLoadingResidents = true;
    });
    try {
      final list = await _cuDanCanHoService.fetchByCanHo(_currentCanHo.id);
      list.sort((a, b) {
        if (a.ngayChuyenDen == null) return 1;
        if (b.ngayChuyenDen == null) return -1;
        return b.ngayChuyenDen!.compareTo(a.ngayChuyenDen!);
      });
      setState(() {
        _residents = list;
      });
    } catch (e) {
      debugPrint('Error loading apartment residents: $e');
    } finally {
      setState(() {
        _isLoadingResidents = false;
      });
    }
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
                      const SizedBox(height: 16),
                      _buildResidentsTimelineSection(),
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

  Widget _buildResidentsTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Cư dân trong căn hộ',
                style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.8),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.tealPrimary, size: 20),
              onPressed: _showAddResidentDialog,
              tooltip: 'Thêm cư dân',
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderButton),
          ),
          child: _isLoadingResidents
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
                )
              : _residents.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'Chưa có cư dân nào',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _residents.length,
                      itemBuilder: (context, index) {
                        final item = _residents[index];
                        final isActive = item.ngayChuyenDi == null;
                        
                        final df = DateFormat('dd/MM/yyyy');
                        final fromStr = item.ngayChuyenDen != null ? df.format(item.ngayChuyenDen!) : '—';
                        final toStr = item.ngayChuyenDi != null ? df.format(item.ngayChuyenDi!) : 'Hiện tại';

                        final cardColor = isActive 
                            ? AppColors.tealPrimary.withOpacity(0.05) 
                            : AppColors.nenContainer;
                        final borderColor = isActive 
                            ? AppColors.tealPrimary.withOpacity(0.25) 
                            : AppColors.borderButton;

                        return Card(
                          color: cardColor,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: borderColor),
                          ),
                          child: InkWell(
                            onTap: () => _navigateResidentDetail(item.cuDanId),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.tenCuDan,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (isActive ? AppColors.tealPrimary : AppColors.iconMuted).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.tenVaiTro.isNotEmpty ? item.tenVaiTro : 'Cư dân',
                                                style: TextStyle(
                                                  color: isActive ? AppColors.tealPrimary : AppColors.textMuted,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'SĐT: ${item.sdtCuDan.isNotEmpty ? item.sdtCuDan : '—'}',
                                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Thời gian ở: $fromStr → $toStr',
                                          style: TextStyle(
                                            color: isActive ? Colors.white70 : AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isActive) ...[
                                    TextButton.icon(
                                      onPressed: () => _checkoutResident(item),
                                      icon: const Icon(Icons.logout_rounded, size: 14, color: AppColors.amber),
                                      label: const Text(
                                        'Chuyển đi',
                                        style: TextStyle(color: AppColors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.red),
                                    onPressed: () => _deleteAssignment(item),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.only(left: 8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAddResidentDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
    );
    List<CuDan> cuDans = [];
    try {
      cuDans = await _cuDanService.fetchCuDans();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách cư dân: $e'), backgroundColor: AppColors.red),
        );
        return;
      }
    }

    if (cuDans.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có cư dân nào trong hệ thống'), backgroundColor: AppColors.red),
        );
      }
      return;
    }

    int? selectedCuDanId = cuDans.first.id;
    int selectedRoleId = 1; // 1 = Chủ hộ, 2 = Thành viên, 3 = Người thuê
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Thêm cư dân vào căn hộ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedCuDanId,
                    dropdownColor: AppColors.bgMid,
                    decoration: const InputDecoration(
                      labelText: 'Chọn cư dân',
                      labelStyle: TextStyle(color: AppColors.tealPrimary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderButton)),
                    ),
                    items: cuDans
                        .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.hoTen, style: const TextStyle(color: Colors.white, fontSize: 14))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCuDanId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedRoleId,
                    dropdownColor: AppColors.bgMid,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò',
                      labelStyle: TextStyle(color: AppColors.tealPrimary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderButton)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Chủ hộ', style: TextStyle(color: Colors.white, fontSize: 14))),
                      DropdownMenuItem(value: 2, child: Text('Thành viên', style: TextStyle(color: Colors.white, fontSize: 14))),
                      DropdownMenuItem(value: 3, child: Text('Người thuê', style: TextStyle(color: Colors.white, fontSize: 14))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedRoleId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.tealPrimary,
                                onPrimary: Colors.white,
                                surface: AppColors.bgMid,
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: AppColors.bgDark,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ngày chuyển đến:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: const TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'cuDanId': selectedCuDanId,
                      'laChuHo': selectedRoleId == 1,
                      'vaiTroId': selectedRoleId,
                      'ngayChuyenDen': selectedDate,
                    });
                  },
                  child: const Text('Thêm', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
      );

      try {
        final success = await _cuDanCanHoService.assignCuDanCanHo({
          'cuDanId': result['cuDanId'],
          'canHoId': _currentCanHo.id,
          'laChuHo': result['laChuHo'],
          'vaiTroId': result['vaiTroId'],
          'ngayChuyenDen': (result['ngayChuyenDen'] as DateTime).toIso8601String(),
        });

        if (!mounted) return;
        Navigator.pop(context); // Dismiss loading

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm cư dân thành công'), backgroundColor: AppColors.tealPrimary),
          );
          _loadResidents();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể thêm cư dân'), backgroundColor: AppColors.red),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _checkoutResident(CuDanCanHo item) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận chuyển đi',
      content: 'Bạn có chắc chắn muốn ghi nhận cư dân ${item.tenCuDan} đã chuyển đi?',
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
      );
      try {
        final success = await _cuDanCanHoService.chuyenDi(item.id);
        if (!mounted) return;
        Navigator.pop(context); // Dismiss loading
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ghi nhận chuyển đi thành công'), backgroundColor: AppColors.tealPrimary),
          );
          _loadResidents();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteAssignment(CuDanCanHo item) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận xóa liên kết',
      content: 'Bạn có chắc chắn muốn xóa liên kết cư dân ${item.tenCuDan} khỏi căn hộ?',
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
      );
      try {
        final success = await _cuDanCanHoService.delete(item.id);
        if (!mounted) return;
        Navigator.pop(context); // Dismiss loading
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa liên kết thành công'), backgroundColor: AppColors.tealPrimary),
          );
          _loadResidents();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  Future<void> _navigateResidentDetail(int cuDanId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
    );
    try {
      final cuDan = await _cuDanService.fetchCuDanById(cuDanId);
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CuDanDetailView(cuDan: cuDan)),
      ).then((_) => _loadResidents());
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }
}
