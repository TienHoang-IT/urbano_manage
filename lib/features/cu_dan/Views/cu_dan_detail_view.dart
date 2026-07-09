import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/cu_dan_model.dart';
import 'package:urbano_manage/features/cu_dan/ViewModels/cu_dan_viewmodel.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_form_view.dart';
import 'package:urbano_manage/Models/cu_dan_can_ho_model.dart';
import 'package:urbano_manage/Services/cu_dan_can_ho_service.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';
import 'package:urbano_manage/features/can_ho/Views/can_ho_detail_view.dart';

class CuDanDetailView extends StatefulWidget {
  final CuDan cuDan;

  const CuDanDetailView({super.key, required this.cuDan});

  @override
  State<CuDanDetailView> createState() => _CuDanDetailViewState();
}

class _CuDanDetailViewState extends State<CuDanDetailView> {
  late CuDan _currentCuDan;
  final CuDanCanHoService _cuDanCanHoService = CuDanCanHoService();
  final CanHoService _canHoService = CanHoService();
  List<CuDanCanHo> _history = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _currentCuDan = widget.cuDan;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final list = await _cuDanCanHoService.fetchByCuDan(_currentCuDan.id);
      list.sort((a, b) {
        if (a.ngayChuyenDen == null) return 1;
        if (b.ngayChuyenDen == null) return -1;
        return b.ngayChuyenDen!.compareTo(a.ngayChuyenDen!);
      });
      if (!mounted) return;
      setState(() {
        _history = list;
      });
    } catch (e) {
      debugPrint('Error loading resident history: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgMid,
          title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          content: Text('Bạn có chắc chắn muốn xóa cư dân ${_currentCuDan.hoTen}?', style: const TextStyle(color: AppColors.textMuted)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Xóa'),
              onPressed: () async {
                final vm = context.read<CuDanViewModel>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                Navigator.of(dialogContext).pop(); // Close dialog
                final success = await vm.removeCuDan(_currentCuDan.id);
                if (mounted) {
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Xóa cư dân thành công')),
                    );
                    navigator.pop(); // Back to list view
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(vm.error ?? 'Lỗi xảy ra khi xóa cư dân')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmVerify(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgMid,
          title: const Text('Xác nhận cư dân', style: TextStyle(color: Colors.white)),
          content: Text('Bạn có chắc chắn muốn xác thực cư dân ${_currentCuDan.hoTen} không?', style: const TextStyle(color: AppColors.textMuted)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.blue),
              child: const Text('Xác thực'),
              onPressed: () async {
                final vm = context.read<CuDanViewModel>();
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop(); // Close dialog
                final success = await vm.verifyCuDan(_currentCuDan.id);
                if (mounted) {
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Xác thực cư dân thành công')),
                    );
                    final updated = vm.cuDans.firstWhere(
                      (c) => c.id == _currentCuDan.id,
                      orElse: () => _currentCuDan,
                    );
                    setState(() {
                      _currentCuDan = updated;
                    });
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(vm.error ?? 'Lỗi xảy ra khi xác thực')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDob = _currentCuDan.ngaySinh != null
        ? DateFormat('dd/MM/yyyy').format(_currentCuDan.ngaySinh!.toLocal())
        : 'Chưa cập nhật';
    final formattedCreatedAt = DateFormat('dd/MM/yyyy HH:mm').format(_currentCuDan.createdAt.toLocal());

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 20),
                      _buildInfoSection('Thông tin cá nhân', [
                        _buildInfoRow(Icons.cake_rounded, 'Ngày sinh', formattedDob),
                        _buildInfoRow(Icons.wc_rounded, 'Giới tính', _currentCuDan.gioiTinhText.isNotEmpty ? _currentCuDan.gioiTinhText : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.badge_rounded, 'Số CCCD', _currentCuDan.cccd.isNotEmpty ? _currentCuDan.cccd : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Thông tin liên lạc', [
                        _buildInfoRow(Icons.phone_rounded, 'Điện thoại', _currentCuDan.sdt.isNotEmpty ? _currentCuDan.sdt : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.email_rounded, 'Email', _currentCuDan.email.isNotEmpty ? _currentCuDan.email : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Địa chỉ', [
                        _buildInfoRow(Icons.location_on_rounded, 'Địa chỉ đầy đủ', _currentCuDan.diaChiDayDu.isNotEmpty ? _currentCuDan.diaChiDayDu : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.map_rounded, 'Phường/Xã', _currentCuDan.xa.isNotEmpty ? _currentCuDan.xa : 'Chưa cập nhật'),
                        _buildInfoRow(Icons.location_city_rounded, 'Tỉnh/Thành phố', _currentCuDan.tinh.isNotEmpty ? _currentCuDan.tinh : 'Chưa cập nhật'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('Hệ thống', [
                        _buildInfoRow(Icons.calendar_today_rounded, 'Ngày tạo', formattedCreatedAt),
                        _buildInfoRow(Icons.check_circle_rounded, 'Trạng thái', _currentCuDan.trangThaiText.isNotEmpty ? _currentCuDan.trangThaiText : 'Hoạt động'),
                      ]),
                      const SizedBox(height: 16),
                      _buildHistoryTimelineSection(),
                      const SizedBox(height: 24),
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
            onTap: () => Navigator.of(context).pop(),
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
              'Chi tiết Cư dân',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          if (_currentCuDan.trangThai == 1)
            IconButton(
              icon: const Icon(Icons.verified_user_rounded, color: AppColors.blue),
              tooltip: 'Xác thực cư dân',
              onPressed: () => _confirmVerify(context),
            ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.tealPrimary),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => CuDanFormView(cuDan: _currentCuDan)),
              );
              if (result == true) {
                // reload current resident detail if VM was updated
                final vm = context.read<CuDanViewModel>();
                final updated = vm.cuDans.firstWhere(
                  (c) => c.id == _currentCuDan.id,
                  orElse: () => _currentCuDan,
                );
                setState(() {
                  _currentCuDan = updated;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final String initial = _currentCuDan.ten.isNotEmpty ? _currentCuDan.ten[0].toUpperCase() : 'C';
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
              child: Text(
                initial,
                style: const TextStyle(color: AppColors.tealPrimary, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentCuDan.hoTen,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSide),
                  ),
                  child: Text(
                    _currentCuDan.trangThaiText.isNotEmpty ? _currentCuDan.trangThaiText : 'Hoạt động',
                    style: const TextStyle(color: AppColors.tealPrimary, fontSize: 11, fontWeight: FontWeight.bold),
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

  Widget _buildHistoryTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Lịch sử Căn hộ đã ở',
            style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.8),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderButton),
          ),
          child: _isLoadingHistory
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
                )
              : _history.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'Chưa từng liên kết căn hộ nào',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        final isActive = item.ngayChuyenDi == null;

                        final df = DateFormat('dd/MM/yyyy');
                        final fromStr = item.ngayChuyenDen != null ? df.format(item.ngayChuyenDen!) : '—';
                        final toStr = item.ngayChuyenDi != null ? df.format(item.ngayChuyenDi!) : 'Hiện tại';

                        final cardColor = isActive 
                            ? AppColors.tealPrimary.withValues(alpha: 0.05) 
                            : AppColors.nenContainer;
                        final borderColor = isActive 
                            ? AppColors.tealPrimary.withValues(alpha: 0.25) 
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
                            onTap: () => _navigateCanHoDetail(item.canHoId),
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
                                              'Căn hộ ${item.soCanHo}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (isActive ? AppColors.tealPrimary : AppColors.iconMuted).withValues(alpha: 0.15),
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
                                          'Tòa nhà: ${item.tenToaNha.isNotEmpty ? item.tenToaNha : '—'}',
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
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
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

  Future<void> _navigateCanHoDetail(int canHoId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
    );
    try {
      final canHo = await _canHoService.fetchCanHoById(canHoId);
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CanHoDetailView(canHo: canHo)),
      ).then((_) {
        if (mounted) _loadHistory();
      });
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
