import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:urbano_manage/Services/bao_cao_service.dart';
import 'package:urbano_manage/Services/cau_hinh_thanh_toan_service.dart';
import 'package:urbano_manage/Models/cau_hinh_thanh_toan_model.dart';
import 'package:urbano_manage/core/network/signalr_service.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_confirm_dialog.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/hoa_don_model.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/features/hoa_don/Views/hoa_don_form_view.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';
import 'package:urbano_manage/Services/lich_su_thanh_toan_service.dart';
import 'package:urbano_manage/Models/lich_su_thanh_toan_model.dart';

class HoaDonDetailView extends StatefulWidget {
  final HoaDon hoaDon;

  const HoaDonDetailView({super.key, required this.hoaDon});

  @override
  State<HoaDonDetailView> createState() => _HoaDonDetailViewState();
}

class _HoaDonDetailViewState extends State<HoaDonDetailView> {
  late HoaDon _currentHoaDon;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _currentHoaDon = widget.hoaDon;
    _loadRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HoaDonViewModel>().fetchChiTiets(_currentHoaDon.id);
    });
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => HoaDonFormView(hoaDon: _currentHoaDon)),
    );

    if (result == true && mounted) {
      try {
        final updated = await HoaDonService().fetchHoaDonById(_currentHoaDon.id);
        if (mounted) {
          setState(() {
            _currentHoaDon = updated;
          });
          context.read<HoaDonViewModel>().fetchChiTiets(_currentHoaDon.id);
        }
      } catch (e) {
        debugPrint('Error reloading invoice: $e');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa hóa đơn ${_currentHoaDon.maThanhToan} khỏi hệ thống?',
    );

    if (confirm == true && mounted) {
      final success = await context.read<HoaDonViewModel>().removeHoaDon(_currentHoaDon.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa hóa đơn thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<HoaDonViewModel>().error ?? 'Không thể xóa hóa đơn'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPayDialog() async {
    final vm = context.read<HoaDonViewModel>();
    final signalR = context.read<SignalRService>();
    final conThieuDialog = _currentHoaDon.tongTien - _currentHoaDon.soTienDaThanhToan;
    final isSecondPayment = _currentHoaDon.soTienDaThanhToan > 0;
    final minAmount = isSecondPayment ? conThieuDialog : conThieuDialog * 0.5;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final amountController = TextEditingController(
      text: isSecondPayment ? conThieuDialog.toInt().toString() : '',
    );
    final refController = TextEditingController(
      text: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
    );
    final noteController = TextEditingController();
    String method = 'Chuyển khoản';
    bool isQrGenerated = false;
    double verifiedPayAmount = 0.0;

    final bankConfigs = await CauHinhThanhToanService().fetchConfigs();
    final bankConfig = bankConfigs.isNotEmpty
        ? bankConfigs.first
        : CauHinhThanhToan(
            id: 1,
            loaiPhuongThuc: 'ChuyenKhoan',
            tenNhaCungCap: 'MBBank',
            dinhDanhThuHuong: '0987654321',
            maNhanDien: 'MB',
            tenChuTaiKhoan: 'BQL CHUNG CU URBANO',
          );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          void signalRListener() async {
            if (signalR.recentEvents.isNotEmpty) {
              final latest = signalR.recentEvents.first;
              final type = latest['_type']?.toString();
              if (type == 'payment_received' || type == 'payment_confirmed') {
                final matchId = latest['hoaDonId'] == _currentHoaDon.id;
                final matchCode = latest['maThanhToan'] != null &&
                    latest['maThanhToan'].toString().toUpperCase() == _currentHoaDon.maThanhToan.toUpperCase();
                if (matchId || matchCode) {
                  signalR.removeListener(signalRListener);
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.pop(dialogContext);
                  }
                  final updated = await HoaDonService().fetchHoaDonById(_currentHoaDon.id);
                  if (mounted) {
                    setState(() {
                      _currentHoaDon = updated;
                    });
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Nhận được thanh toán chuyển khoản cho hóa đơn ${_currentHoaDon.maThanhToan}!'),
                        backgroundColor: AppColors.tealPrimary,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              }
            }
          }

          if (isQrGenerated) {
            signalR.addListener(signalRListener);
          }

          bool validateAmount() {
            final rawAmount = amountController.text.trim();
            if (rawAmount.isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập số tiền thanh toán')),
              );
              return false;
            }

            final amount = double.tryParse(rawAmount);
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập số tiền thanh toán hợp lệ')),
              );
              return false;
            }

            if (isSecondPayment) {
              if ((amount - conThieuDialog).abs() > 0.01) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Do đã thanh toán 1 phần, lần này bắt buộc phải thanh toán toàn bộ số tiền còn thiếu (${currencyFormat.format(conThieuDialog)})'),
                    backgroundColor: AppColors.red,
                  ),
                );
                return false;
              }
            } else {
              if (amount <= minAmount) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Số tiền thanh toán lần đầu phải lớn hơn 50% số tiền còn thiếu (tối thiểu lớn hơn ${currencyFormat.format(minAmount)})'),
                    backgroundColor: AppColors.red,
                  ),
                );
                return false;
              }

              if (amount > conThieuDialog) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Số tiền thanh toán không được vượt quá số tiền còn thiếu (${currencyFormat.format(conThieuDialog)})'),
                    backgroundColor: AppColors.red,
                  ),
                );
                return false;
              }
            }

            verifiedPayAmount = amount;
            return true;
          }

          return AlertDialog(
            backgroundColor: AppColors.bgMid,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: AppColors.borderButton),
            ),
            title: Text(
              'Ghi nhận thanh toán', 
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20, letterSpacing: -0.5)
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSecondPayment 
                          ? AppColors.amber.withValues(alpha: 0.1)
                          : AppColors.tealPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSecondPayment
                            ? AppColors.amber.withValues(alpha: 0.4)
                            : AppColors.tealPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Số tiền còn thiếu: ${currencyFormat.format(conThieuDialog)}',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        if (isSecondPayment) ...[
                          Text(
                            'Yêu cầu: Thanh toán 100% số tiền còn lại (${currencyFormat.format(conThieuDialog)})',
                            style: TextStyle(color: AppColors.amber, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ] else ...[
                          Text(
                            'Cần thanh toán lần đầu (>50%): > ${currencyFormat.format(minAmount)}',
                            style: TextStyle(color: AppColors.tealPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hint: isSecondPayment
                        ? 'Số tiền còn lại (${currencyFormat.format(conThieuDialog)})'
                        : 'Nhập số tiền thanh toán (>50%)',
                    label: 'SỐ TIỀN THANH TOÁN (VND) *',
                    controller: amountController,
                    prefixIcon: Icons.price_check_rounded,
                    keyboardType: TextInputType.number,
                    readOnly: isQrGenerated,
                    onChanged: (_) {
                      if (isQrGenerated) {
                        setDialogState(() {
                          isQrGenerated = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDropdownField<String>(
                    label: 'PHƯƠNG THỨC *',
                    value: method,
                    hint: 'Chọn phương thức',
                    prefixIcon: Icons.payment_rounded,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          method = val;
                          isQrGenerated = false;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'Chuyển khoản', child: Text('Chuyển khoản')),
                      DropdownMenuItem(value: 'Tiền mặt', child: Text('Tiền mặt')),
                    ],
                  ),
                  if (method == 'Chuyển khoản') ...[
                    const SizedBox(height: 16),
                    if (!isQrGenerated) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tealPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            if (validateAmount()) {
                              setDialogState(() {
                                isQrGenerated = true;
                              });
                            }
                          },
                          icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                          label: const Text(
                            'TẠO MÃ QR THANH TOÁN',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.qr_code_2_rounded, color: AppColors.tealPrimary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'MÃ QR VIETQR KHÓP SỐ TIỀN',
                                      style: TextStyle(color: AppColors.tealPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      isQrGenerated = false;
                                    });
                                  },
                                  child: Text(
                                    'Sửa số tiền',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 12, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildBankInfoRow('Ngân hàng', bankConfig.tenNhaCungCap, null),
                            const SizedBox(height: 8),
                            _buildBankInfoRow('Số tài khoản', bankConfig.dinhDanhThuHuong, () {
                              Clipboard.setData(ClipboardData(text: bankConfig.dinhDanhThuHuong));
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('Đã sao chép số tài khoản'), duration: Duration(seconds: 2)),
                              );
                            }),
                            const SizedBox(height: 8),
                            _buildBankInfoRow('Chủ tài khoản', bankConfig.tenChuTaiKhoan, null),
                            const SizedBox(height: 8),
                            _buildBankInfoRow('Số tiền chuyển', currencyFormat.format(verifiedPayAmount), null),
                            const SizedBox(height: 8),
                            _buildBankInfoRow('Nội dung CK', _currentHoaDon.maThanhToan, () {
                              Clipboard.setData(ClipboardData(text: _currentHoaDon.maThanhToan));
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('Đã sao chép nội dung chuyển khoản'), duration: Duration(seconds: 2)),
                              );
                            }),
                            const SizedBox(height: 14),
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Image.network(
                                      'https://img.vietqr.io/image/${bankConfig.maNhanDien}-${bankConfig.dinhDanhThuHuong}-compact2.png?amount=${verifiedPayAmount.toInt()}&addInfo=${Uri.encodeComponent(_currentHoaDon.maThanhToan)}&accountName=${Uri.encodeComponent(bankConfig.tenChuTaiKhoan)}',
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 180,
                                        height: 180,
                                        alignment: Alignment.center,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealPrimary),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Đang chờ nhận chuyển khoản...',
                                        style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  AppTextField(
                    hint: 'Nhập mã giao dịch',
                    label: 'MÃ GIAO DỊCH',
                    controller: refController,
                    prefixIcon: Icons.receipt_rounded,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hint: 'Nhập ghi chú',
                    label: 'GHI CHÚ',
                    controller: noteController,
                    prefixIcon: Icons.notes_rounded,
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              TextButton(
                onPressed: () {
                  signalR.removeListener(signalRListener);
                  Navigator.pop(dialogContext);
                },
                child: Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (!validateAmount()) return;

                  final amount = verifiedPayAmount;
                  final ref = refController.text.trim();
                  final note = noteController.text.trim();
                  
                  signalR.removeListener(signalRListener);
                  Navigator.pop(dialogContext); // Close dialog
                  if (!mounted) return;

                  final data = {
                    'soTien': amount,
                    'phuongThucThanhToan': method,
                    'maGiaoDich': ref,
                    'ghiChu': note,
                  };

                  try {
                    final success = await vm.recordPayment(_currentHoaDon.id, data);
                    if (success && mounted) {
                      final updated = await HoaDonService().fetchHoaDonById(_currentHoaDon.id);
                      if (mounted) {
                        setState(() {
                          _currentHoaDon = updated;
                        });
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Ghi nhận thanh toán thành công'), backgroundColor: AppColors.tealPrimary),
                        );
                      }
                    } else if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(vm.error ?? 'Không thể ghi nhận thanh toán'), backgroundColor: AppColors.red),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red),
                      );
                    }
                  }
                },
                child: Text('Xác nhận', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );

    amountController.dispose();
    refController.dispose();
    noteController.dispose();
  }

  Widget _buildBankInfoRow(String label, String value, VoidCallback? onCopy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Row(
          children: [
            Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            if (onCopy != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onCopy,
                child: Icon(Icons.copy_rounded, color: AppColors.tealPrimary, size: 16),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedDueDate = _currentHoaDon.hanThanhToan != null
        ? DateFormat('dd/MM/yyyy').format(_currentHoaDon.hanThanhToan!.toLocal())
        : 'Chưa cập nhật';
    final formattedCreatedAt = DateFormat('dd/MM/yyyy HH:mm').format(_currentHoaDon.createdAt.toLocal());
    
    Color statusColor;
    switch (_currentHoaDon.displayTrangThai) {
      case 1:
        statusColor = AppColors.red;
        break;
      case 2:
        statusColor = AppColors.amber;
        break;
      case 3:
        statusColor = AppColors.tealPrimary;
        break;
      case 4:
        statusColor = AppColors.red;
        break;
      default:
        statusColor = AppColors.red;
    }

    final conThieu = _currentHoaDon.tongTien - _currentHoaDon.soTienDaThanhToan;

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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(statusColor, currencyFormat),
                      const SizedBox(height: 24),
                      if (_currentHoaDon.trangThai != 3 && _currentHoaDon.soTienDaThanhToan < _currentHoaDon.tongTien) ...[
                        AppButton(
                          label: 'Ghi Nhận Thanh Toán',
                          icon: Icons.payments_rounded,
                          onPressed: _showPayDialog,
                        ),
                        const SizedBox(height: 24),
                      ],
                      _buildInfoSection('Chi tiết hóa đơn', [
                        _buildInfoRow(Icons.apartment_rounded, 'Căn hộ', '${_currentHoaDon.soCanHo.isNotEmpty ? _currentHoaDon.soCanHo : _currentHoaDon.canHo} (ID: ${_currentHoaDon.canHo})'),
                        _buildInfoRow(Icons.calendar_view_month_rounded, 'Kỳ hóa đơn', 'Tháng ${_currentHoaDon.thang}/${_currentHoaDon.nam}'),
                        _buildInfoRow(Icons.timer_rounded, 'Hạn thanh toán', formattedDueDate),
                      ]),
                      const SizedBox(height: 24),
                      _buildChiTietSection(currencyFormat),
                      const SizedBox(height: 24),
                      _buildInfoSection('Thông tin thanh toán', [
                        _buildInfoRow(Icons.price_change_rounded, 'Chi phí dịch vụ', currencyFormat.format(_currentHoaDon.chiPhi)),
                        _buildInfoRow(Icons.payment_rounded, 'Đã thanh toán', currencyFormat.format(_currentHoaDon.soTienDaThanhToan)),
                        _buildInfoRow(Icons.money_off_rounded, 'Còn thiếu', currencyFormat.format(conThieu < 0 ? 0.0 : conThieu)),
                      ]),
                      const SizedBox(height: 24),
                      _buildInfoSection('Thông tin cập nhật', [
                        _buildInfoRow(Icons.person_outline_rounded, 'Người cập nhật', _currentHoaDon.tenNguoiCapNhat.isNotEmpty ? _currentHoaDon.tenNguoiCapNhat : 'N/A'),
                        _buildInfoRow(Icons.calendar_today_rounded, 'Ngày khởi tạo', formattedCreatedAt),
                      ]),
                      const SizedBox(height: 24),
                      _buildLichSuThanhToanSection(),
                      const SizedBox(height: 32),
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
    final isQuanLy = _role == 'Quản lý';
    final isKeToan = _role == 'Kế toán' || isQuanLy;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true), // Return true to refresh list if needed
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Chi tiết Hóa đơn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (isKeToan) ...[
            GestureDetector(
              onTap: _exportBienLaiPdf,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderButton),
                ),
                child: Icon(Icons.picture_as_pdf_rounded, size: 20, color: AppColors.tealPrimary),
              ),
            ),
            const SizedBox(width: 10),
          ],
          GestureDetector(
            onTap: () => _navigateToEdit(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.edit_rounded, size: 20, color: AppColors.tealPrimary),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: Icon(Icons.delete_rounded, size: 20, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color statusColor, NumberFormat currencyFormat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentHoaDon.maThanhToan,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentHoaDon.trangThaiText,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tổng tiền thanh toán',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            currencyFormat.format(_currentHoaDon.tongTien),
            style: TextStyle(color: statusColor, fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1, height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildChiTietSection(NumberFormat currencyFormat) {
    final details = context.watch<HoaDonViewModel>().currentChiTiets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Phí dịch vụ chi tiết',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: -0.5),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderButton),
          ),
          child: details.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
                  child: Center(
                    child: Text(
                      'Chưa có dịch vụ chi tiết nào.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: details.length,
                  separatorBuilder: (_, _) => Divider(color: AppColors.borderButton, height: 1),
                  itemBuilder: (context, index) {
                    final item = details[index];
                    final name = item['tenPhiDichVu'] as String? ?? 'Dịch vụ';
                    final donGia = (item['donGia'] as num? ?? 0).toDouble();
                    final qty = (item['soLuong'] as num? ?? 0).toDouble();
                    final total = (item['thanhTien'] as num? ?? 0).toDouble();
                    final sc = item['chiSoCu'] as int?;
                    final sm = item['chiSoMoi'] as int?;

                    String subtitle = '${qty.toStringAsFixed(0)} x ${currencyFormat.format(donGia)}';
                    if (sc != null && sm != null) {
                      subtitle += ' (Chỉ số: $sc ➔ $sm)';
                    }

                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(total),
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String sectionTitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            sectionTitle,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: -0.5),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.nenContainer,
            borderRadius: BorderRadius.circular(24),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBienLaiPdf() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xuất PDF không khả dụng trên Flutter Web'), backgroundColor: AppColors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
    );

    try {
      final service = BaoCaoService();
      final bytes = await service.getBienLaiPdf(_currentHoaDon.id);
      
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/BienLai_HoaDon_${_currentHoaDon.maThanhToan}.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading

      final openResult = await OpenFile.open(path);
      if (openResult.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở file: ${openResult.message}'), backgroundColor: AppColors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Widget _buildLichSuThanhToanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Lịch sử thanh toán',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: -0.5),
          ),
        ),
        FutureBuilder<List<LichSuThanhToan>>(
          future: LichSuThanhToanService().fetchByHoaDon(_currentHoaDon.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppColors.tealPrimary),
              ));
            }
            if (snapshot.hasError) {
              return Text('Lỗi tải dữ liệu: ${snapshot.error}', style: TextStyle(color: AppColors.red));
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: AppColors.nenContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderButton),
                ),
                child: Center(
                  child: Text(
                    'Chưa có giao dịch nào.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.nenContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, _) => Divider(color: AppColors.borderButton, height: 1),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GD: ${item.maGiaoDich}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(
                                '${item.phuongThucThanhToan} | ${item.ngayThanhToan != null ? DateFormat('dd/MM/yyyy HH:mm').format(item.ngayThanhToan!.toLocal()) : ''}',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.soTien),
                          style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
