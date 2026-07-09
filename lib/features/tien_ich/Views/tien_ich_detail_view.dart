import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano_manage/Services/dat_lich_tien_ich_service.dart';
import 'package:urbano_manage/features/tien_ich/ViewModels/tien_ich_viewmodel.dart';
import 'package:urbano_manage/features/tien_ich/Views/tien_ich_form_view.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';

class TienIchDetailView extends StatefulWidget {
  final int id;

  const TienIchDetailView({super.key, required this.id});

  @override
  State<TienIchDetailView> createState() => _TienIchDetailViewState();
}

class _TienIchDetailViewState extends State<TienIchDetailView> {
  TienIch? _tienIch;
  List<DatLichTienIch> _bookings = [];
  bool _isLoadingTienIch = true;
  bool _isLoadingBookings = true;
  String? _errorTienIch;
  String? _errorBookings;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingTienIch = true;
      _isLoadingBookings = true;
      _errorTienIch = null;
      _errorBookings = null;
    });

    final vm = context.read<TienIchViewModel>();
    try {
      final updatedItem = await vm.fetchTienIchs().then((_) {
        return vm.items.firstWhere((element) => element.id == widget.id);
      });
      if (!mounted) return;
      setState(() {
        _tienIch = updatedItem;
        _isLoadingTienIch = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorTienIch = 'Không thể tải chi tiết tiện ích';
          _isLoadingTienIch = false;
        });
      }
    }

    try {
      final bookings = await DatLichTienIchService().getByTienIch(widget.id);
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoadingBookings = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorBookings = 'Không thể tải lịch đặt';
          _isLoadingBookings = false;
        });
      }
    }
  }

  Future<void> _deleteItem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const AppConfirmDialog(
        title: 'Xác nhận xóa',
        content: 'Bạn có chắc chắn muốn xóa tiện ích này? Tất cả các lịch đặt liên quan sẽ bị ảnh hưởng.',
        confirmText: 'XÓA',
        cancelText: 'HỦY',
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.tealPrimary),
        ),
      );

      final vm = context.read<TienIchViewModel>();
      final success = await vm.delete(widget.id);

      if (mounted) {
        Navigator.pop(context); // Pop loading dialog
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa tiện ích thành công'), backgroundColor: AppColors.tealPrimary),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.error ?? 'Lỗi khi xóa tiện ích'), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: _isLoadingTienIch
              ? const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary))
              : _errorTienIch != null
                  ? _buildErrorWidget()
                  : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorTienIch!, style: const TextStyle(color: AppColors.red, fontSize: 14)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary),
            onPressed: _loadData,
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final item = _tienIch!;
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final feeText = item.phiSuDung == 0 ? 'Miễn phí' : currencyFormatter.format(item.phiSuDung);

    Color statusColor;
    switch (item.trangThai) {
      case 1:
        statusColor = AppColors.tealPrimary;
        break;
      case 2:
        statusColor = AppColors.amber;
        break;
      default:
        statusColor = AppColors.red;
    }

    return Column(
      children: [
        _buildAppbar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.hinhUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.hinhUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    ),
                  )
                else
                  _buildImagePlaceholder(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tenTienIch,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.tenLoaiTienIch,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.tealPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        item.trangThaiText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.borderButton, height: 32, thickness: 1),
                _buildInfoRow(Icons.location_on_rounded, 'Vị trí',
                    item.toaNhaId != null ? '${item.viTri} - ${item.tenToaNha}' : item.viTri),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.people_rounded, 'Sức chứa',
                    item.sucChua != null ? '${item.sucChua} người' : 'Không giới hạn'),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time_rounded,
                  'Giờ hoạt động',
                  item.gioMoCua != null && item.gioDongCua != null
                      ? '${item.gioMoCua!.substring(0, 5)} - ${item.gioDongCua!.substring(0, 5)}'
                      : 'Cả ngày',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.monetization_on_rounded, 'Phí sử dụng', feeText),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.check_circle_outline_rounded,
                  'Đăng ký đặt lịch',
                  item.canDatTruoc ? 'Cần đặt trước' : 'Sử dụng tự do',
                ),
                const SizedBox(height: 16),
                if (item.moTa.isNotEmpty) ...[
                  const Text(
                    'MÔ TẢ TIỆN ÍCH',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.nenContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderButton),
                    ),
                    child: Text(
                      item.moTa,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildBookingsSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.iconMuted),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LỊCH ĐẶT SỬ DỤNG',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingBookings)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.tealPrimary),
            ),
          )
        else if (_errorBookings != null)
          Text(_errorBookings!, style: const TextStyle(color: AppColors.red))
        else if (_bookings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.nenContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: const Center(
              child: Text(
                'Chưa có lịch đặt nào cho tiện ích này',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingItem(_bookings[index]);
            },
          ),
      ],
    );
  }

  Widget _buildBookingItem(DatLichTienIch booking) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final timeStr = '${df.format(booking.thoiGianBatDau.toLocal())} - ${df.format(booking.thoiGianKetThuc.toLocal())}';

    Color statusColor;
    switch (booking.trangThai) {
      case 1:
        statusColor = AppColors.amber;
        break;
      case 2:
        statusColor = AppColors.blue;
        break;
      case 3:
        statusColor = AppColors.red;
        break;
      case 4:
        statusColor = AppColors.textMuted;
        break;
      case 5:
        statusColor = AppColors.tealPrimary;
        break;
      default:
        statusColor = AppColors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.tenCuDan,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  booking.trangThaiText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.home_rounded, size: 14, color: AppColors.iconMuted),
              const SizedBox(width: 6),
              Text(
                'Căn hộ: ${booking.soCanHo.isNotEmpty ? booking.soCanHo : "Chưa chọn"}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.iconMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  timeStr,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          if (booking.ghiChu.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Ghi chú: ${booking.ghiChu}',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 50,
          color: AppColors.iconMuted,
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.tealPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết Tiện ích',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.tealPrimary),
                onPressed: () async {
                  final vm = context.read<TienIchViewModel>();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: AppColors.tealPrimary),
                    ),
                  );
                  await vm.loadFormDropdowns();
                  if (context.mounted) {
                    Navigator.pop(context); // Pop loading dialog
                    if (vm.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(vm.error!), backgroundColor: AppColors.red),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TienIchFormView(tienIch: _tienIch),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadData();
                        }
                      });
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: AppColors.red),
                onPressed: () => _deleteItem(context),
              ),
            ],
          )
        ],
      ),
    );
  }
}
