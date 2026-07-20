import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:urbano_manage/Services/bao_cao_service.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/ViewModels/yeu_cau_cu_dan_viewmodel.dart';
import 'package:urbano_manage/features/thong_bao/ViewModels/thong_bao_viewmodel.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/ViewModels/dat_lich_tien_ich_viewmodel.dart';
import 'package:urbano_manage/features/main_shell/Views/global_search_delegate.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/theme_provider.dart';
import 'package:urbano_manage/core/constants/navigation_tabs.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';
import 'package:urbano_manage/features/auth/Views/login_view.dart';
import 'package:urbano_manage/features/dashboard/Views/dashboard_view.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/Views/yeu_cau_cu_dan_view.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_list_view.dart';
import 'package:urbano_manage/features/hoa_don/Views/hoa_don_list_view.dart';
import 'package:urbano_manage/features/thong_bao/Views/thong_bao_list_view.dart';
import 'package:urbano_manage/features/nhan_vien/Views/nhan_vien_list_view.dart';
import 'package:urbano_manage/features/can_ho/Views/can_ho_list_view.dart';
import 'package:urbano_manage/features/phi_dich_vu/Views/phi_dich_vu_list_view.dart';
import 'package:urbano_manage/features/bang_tin/Views/bang_tin_list_view.dart';
import 'package:urbano_manage/features/phuong_tien/Views/phuong_tien_list_view.dart';
import 'package:urbano_manage/features/nhat_ky_he_thong/Views/nhat_ky_he_thong_list_view.dart';
import 'package:urbano_manage/features/tien_ich/Views/tien_ich_list_view.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/Views/dat_lich_list_view.dart';
import 'package:urbano_manage/core/network/signalr_service.dart';
import 'package:urbano_manage/core/services/local_notification_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = NavigationTabs.dashboard;
  String _employeeName = '';
  String _employeeCode = '';
  String _role = '';
  int _employeeId = 0;
  final Map<int, bool> _needsRefresh = {};

  int _lastTotalUnread = 0;
  Timer? _debounceTimer;
  StreamSubscription<String?>? _notificationSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadEmployeeInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final signalR = Provider.of<SignalRService>(context, listen: false);
      if (!signalR.isConnected) signalR.connect();
      signalR.addListener(_onSignalRUpdate);

      _notificationSub = LocalNotificationService.onNotificationTap.stream.listen((payload) {
        if (payload != null) {
          _handleNotificationTap(payload);
        }
      });
    });
  }

  void _handleNotificationTap(String payload) {
    if (!mounted) return;
    int? targetTab;
    
    switch (payload) {
      case 'new_invoice':
      case 'payment_received':
        targetTab = NavigationTabs.hoaDon;
        break;
      case 'new_request':
      case 'request_status':
        targetTab = NavigationTabs.yeuCauCuDan;
        break;
      case 'new_booking':
      case 'booking_status':
        targetTab = NavigationTabs.datLichTienIch;
        break;
      case 'notification':
      case 'system_alert':
        targetTab = NavigationTabs.thongBao;
        break;
    }
    
    if (targetTab != null && _currentIndex != targetTab) {
      _onNavigate(targetTab);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _notificationSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (mounted) {
      Provider.of<SignalRService>(context, listen: false).removeListener(_onSignalRUpdate);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!mounted) return;
      final signalR = Provider.of<SignalRService>(context, listen: false);
      if (!signalR.isConnected) signalR.connect();
    }
  }

  void _onSignalRUpdate() {
    if (!mounted) return;
    final signalR = Provider.of<SignalRService>(context, listen: false);
    if (signalR.totalUnread > _lastTotalUnread) {
       final latest = signalR.recentEvents.isNotEmpty ? signalR.recentEvents.first : null;
       if (latest != null) {
         final type = latest['_type']?.toString();
         if (type != null) {
           _debounceTimer?.cancel();
           _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
             if (!mounted) return;
             if (type == 'new_request') {
               if (_currentIndex == NavigationTabs.yeuCauCuDan) {
                 context.read<YeuCauCuDanViewModel>().fetchRequests();
               } else {
                 _needsRefresh[NavigationTabs.yeuCauCuDan] = true;
               }
             } else if (type == 'notification') {
               if (_currentIndex == NavigationTabs.thongBao) {
                 context.read<ThongBaoViewModel>().fetchThongBaos();
               } else {
                 _needsRefresh[NavigationTabs.thongBao] = true;
               }
             } else if (type == 'new_booking') {
               if (_currentIndex == NavigationTabs.datLichTienIch) {
                 context.read<DatLichTienIchViewModel>().fetchBookings();
               } else {
                 _needsRefresh[NavigationTabs.datLichTienIch] = true;
               }
             } else if (type == 'payment_received') {
               if (_currentIndex == NavigationTabs.hoaDon) {
                 context.read<HoaDonViewModel>().fetchHoaDons();
               } else {
                 _needsRefresh[NavigationTabs.hoaDon] = true;
               }
             }
           });
         }
       }
    }
    _lastTotalUnread = signalR.totalUnread;
  }

  Future<void> _loadEmployeeInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nvStr = prefs.getString('nhanVien');
      final role = prefs.getString('role') ?? '';
      if (nvStr != null) {
        final nvMap = jsonDecode(nvStr) as Map<String, dynamic>;
        final nv = NhanVien.fromJson(nvMap);
        setState(() {
          _employeeName = nv.hoTen;
          _employeeCode = nv.maNhanVien;
          _employeeId = nv.id;
          _role = role;
        });
      } else {
        setState(() {
          _role = role;
        });
      }
    } catch (e) {
      debugPrint('Error loading employee info: $e');
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgMid,
          title: Text('Xác nhận đăng xuất', style: TextStyle(color: AppColors.textPrimary)),
          content: Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?', style: TextStyle(color: AppColors.textMuted)),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Đăng xuất'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (mounted) {
        Provider.of<SignalRService>(context, listen: false).disconnect();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('nhanVien');
      await prefs.remove('role');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (_needsRefresh[index] == true) {
      if (index == NavigationTabs.yeuCauCuDan) {
        context.read<YeuCauCuDanViewModel>().fetchRequests();
      } else if (index == NavigationTabs.thongBao) {
        context.read<ThongBaoViewModel>().fetchThongBaos();
      } else if (index == NavigationTabs.datLichTienIch) {
        context.read<DatLichTienIchViewModel>().fetchBookings();
      } else if (index == NavigationTabs.hoaDon) {
        context.read<HoaDonViewModel>().fetchHoaDons();
      }
      _needsRefresh[index] = false;
    }
  }

  Widget _buildAppBar() {
    String title = '';
    switch (_currentIndex) {
      case NavigationTabs.dashboard:
        title = 'Tổng quan';
        break;
      case NavigationTabs.cuDan:
        title = 'Cư dân';
        break;
      case NavigationTabs.canHo:
        title = 'Căn hộ';
        break;
      case NavigationTabs.hoaDon:
        title = 'Hóa đơn';
        break;
      case NavigationTabs.phiDichVu:
        title = 'Phí dịch vụ';
        break;
      case NavigationTabs.yeuCauCuDan:
        title = 'Yêu cầu cư dân';
        break;
      case NavigationTabs.thongBao:
        title = 'Thông báo';
        break;
      case NavigationTabs.nhanVien:
        title = 'Nhân viên';
        break;
      case NavigationTabs.bangTin:
        title = 'Bảng tin';
        break;
      case NavigationTabs.phuongTien:
        title = 'Phương tiện';
        break;
      case NavigationTabs.nhatKyHeThong:
        title = 'Lịch sử hoạt động';
        break;
      case NavigationTabs.tienIch:
        title = 'Tiện ích';
        break;
      case NavigationTabs.datLichTienIch:
        title = 'Đặt lịch tiện ích';
        break;
    }

    final isQuanLy = _role == 'Quản lý';
    final isKeToan = _role == 'Kế toán' || isQuanLy;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderButton),
                ),
                child: Icon(Icons.menu_rounded, size: 22, color: AppColors.tealPrimary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search_rounded, color: AppColors.tealPrimary),
            tooltip: 'Tìm kiếm toàn cục',
            onPressed: () {
              showSearch(
                context: context,
                delegate: GlobalSearchDelegate(),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AppColors.amber,
                ),
                tooltip: 'Đổi giao diện',
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          if (_currentIndex == NavigationTabs.hoaDon && isKeToan) ...[
            IconButton(
              icon: Icon(Icons.auto_awesome_rounded, color: AppColors.tealPrimary),
              tooltip: 'Tạo hóa đơn tháng',
              onPressed: _showAutoBillingDialog,
            ),
            IconButton(
              icon: Icon(Icons.download_rounded, color: AppColors.tealPrimary),
              tooltip: 'Xuất báo cáo',
              onPressed: _showExportBottomSheet,
            ),
          ],
        ],
      ),
    );
  }

  void _showAutoBillingDialog() async {
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Tạo hóa đơn tháng', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hệ thống sẽ tự động tạo hóa đơn dịch vụ cho tất cả căn hộ trong tháng đã chọn.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedMonth,
                          dropdownColor: AppColors.bgMid,
                          decoration: InputDecoration(
                            labelText: 'Tháng',
                            labelStyle: TextStyle(color: AppColors.tealPrimary),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderButton)),
                          ),
                          items: List.generate(12, (index) => index + 1)
                              .map((m) => DropdownMenuItem(value: m, child: Text('$m', style: TextStyle(color: AppColors.textPrimary))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedMonth = val;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedYear,
                          dropdownColor: AppColors.bgMid,
                          decoration: InputDecoration(
                            labelText: 'Năm',
                            labelStyle: TextStyle(color: AppColors.tealPrimary),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderButton)),
                          ),
                          items: List.generate(5, (index) => DateTime.now().year - 2 + index)
                              .map((y) => DropdownMenuItem(value: y, child: Text('$y', style: TextStyle(color: AppColors.textPrimary))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedYear = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'month': selectedMonth, 'year': selectedYear});
                  },
                  child: Text('Xác nhận', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final month = result['month']!;
      final year = result['year']!;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
      );

      try {
        final vm = context.read<HoaDonViewModel>();
        final response = await vm.runAutoBilling(month, year, _employeeId);

        if (!mounted) return;
        Navigator.pop(context); // Dismiss loading

        if (response != null) {
          final totalCreated = response['totalCreated'] ?? 0;
          final skipped = response['skipped'] ?? 0;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.bgMid,
              title: Text('Kết quả', style: TextStyle(color: AppColors.textPrimary)),
              content: Text(
                'Tạo hóa đơn thành công cho tháng $month/$year.\n- Đã tạo: $totalCreated hóa đơn\n- Bỏ qua: $skipped hóa đơn (đã tồn tại)',
                style: TextStyle(color: AppColors.textPrimary70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Đóng', style: TextStyle(color: AppColors.tealPrimary)),
                )
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.bgMid,
              title: Text('Thất bại', style: TextStyle(color: AppColors.red)),
              content: Text(
                vm.error ?? 'Có lỗi xảy ra khi tạo hóa đơn tự động.',
                style: TextStyle(color: AppColors.textPrimary70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Đóng', style: TextStyle(color: AppColors.red)),
                )
              ],
            ),
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

  void _showExportBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Xuất Báo Cáo',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn loại báo cáo bạn muốn tải xuống máy của mình.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.receipt_long_rounded, color: AppColors.textPrimary),
                label: Text('Báo cáo hóa đơn tháng (Excel)', style: TextStyle(color: AppColors.textPrimary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _promptMonthYearAndExport(isHoaDon: true);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.monetization_on_rounded, color: AppColors.textPrimary),
                label: Text('Báo cáo thu phí tháng (Excel)', style: TextStyle(color: AppColors.textPrimary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.borderButton),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _promptMonthYearAndExport(isHoaDon: false);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _promptMonthYearAndExport({required bool isHoaDon}) async {
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isHoaDon ? 'Xuất báo cáo Hóa đơn' : 'Xuất báo cáo Thu phí',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedMonth,
                      dropdownColor: AppColors.bgMid,
                      decoration: InputDecoration(
                        labelText: 'Tháng',
                        labelStyle: TextStyle(color: AppColors.tealPrimary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderButton)),
                      ),
                      items: List.generate(12, (index) => index + 1)
                          .map((m) => DropdownMenuItem(value: m, child: Text('$m', style: TextStyle(color: AppColors.textPrimary))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedMonth = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedYear,
                      dropdownColor: AppColors.bgMid,
                      decoration: InputDecoration(
                        labelText: 'Năm',
                        labelStyle: TextStyle(color: AppColors.tealPrimary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderButton)),
                      ),
                      items: List.generate(5, (index) => DateTime.now().year - 2 + index)
                          .map((y) => DropdownMenuItem(value: y, child: Text('$y', style: TextStyle(color: AppColors.textPrimary))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedYear = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'month': selectedMonth, 'year': selectedYear});
                  },
                  child: Text('Xuất', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final month = result['month']!;
      final year = result['year']!;
      
      _exportExcelReport(isHoaDon: isHoaDon, month: month, year: year);
    }
  }

  Future<void> _exportExcelReport({required bool isHoaDon, required int month, required int year}) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xuất Excel không khả dụng trên Flutter Web'), backgroundColor: AppColors.red),
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
      final bytes = isHoaDon 
          ? await service.getHoaDonExcel(month, year) 
          : await service.getThuPhiExcel(month, year);
      
      final directory = await getTemporaryDirectory();
      final prefix = isHoaDon ? 'BaoCao_HoaDon' : 'BaoCao_ThuPhi';
      final path = '${directory.path}/${prefix}_${month}_$year.xlsx';
      
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

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        DashboardView(onNavigate: _onNavigate),
        const CuDanListView(),
        const CanHoListView(),
        const HoaDonListView(),
        const PhiDichVuListView(),
        const YeuCauCuDanView(),
        const ThongBaoListView(),
        const NhanVienListView(),
        const BangTinListView(),
        const PhuongTienListView(),
        const TienIchListView(),
        const DatLichListView(),
        const NhatKyHeThongListView(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: _buildDrawer(),
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
              Consumer<SignalRService>(
                builder: (_, signalR, _) {
                  if (!signalR.isConnected) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      color: AppColors.red,
                      child: Text('Mất kết nối', textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              _buildAppBar(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final isQuanLy = _role == 'Quản lý';
    final isKeToan = _role == 'Kế toán' || isQuanLy;
    final isBaoVe = _role == 'Bảo vệ' || isQuanLy;

    return Drawer(
      backgroundColor: AppColors.bgDark,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(NavigationTabs.dashboard, 'Tổng quan', Icons.dashboard_rounded),
                if (isKeToan) _buildDrawerItem(NavigationTabs.cuDan, 'Cư dân', Icons.people_alt_rounded),
                if (isKeToan) _buildDrawerItem(NavigationTabs.canHo, 'Căn hộ', Icons.apartment_rounded),
                if (isKeToan)
                  Consumer<SignalRService>(
                    builder: (_, signalR, _) => _buildDrawerItem(
                      NavigationTabs.hoaDon,
                      'Hóa đơn',
                      Icons.receipt_long_rounded,
                      trailing: (signalR.unreadCounts['hoaDon'] ?? 0) > 0 ? _buildBadge(signalR.unreadCounts['hoaDon']!) : null,
                      onTapAction: () => signalR.clearUnreadFor('hoaDon'),
                    ),
                  ),
                if (isKeToan) _buildDrawerItem(NavigationTabs.phiDichVu, 'Phí dịch vụ', Icons.monetization_on_rounded),
                Consumer<SignalRService>(
                  builder: (_, signalR, _) => _buildDrawerItem(
                    NavigationTabs.yeuCauCuDan,
                    'Yêu cầu cư dân',
                    Icons.support_agent_rounded,
                    trailing: (signalR.unreadCounts['yeuCau'] ?? 0) > 0 ? _buildBadge(signalR.unreadCounts['yeuCau']!) : null,
                    onTapAction: () => signalR.clearUnreadFor('yeuCau'),
                  ),
                ),
                Consumer<SignalRService>(
                  builder: (_, signalR, _) => _buildDrawerItem(
                    NavigationTabs.thongBao,
                    'Thông báo',
                    Icons.notifications_rounded,
                    trailing: (signalR.unreadCounts['thongBao'] ?? 0) > 0 ? _buildBadge(signalR.unreadCounts['thongBao']!) : null,
                    onTapAction: () => signalR.clearUnreadFor('thongBao'),
                  ),
                ),
                if (isQuanLy) _buildDrawerItem(NavigationTabs.nhanVien, 'Nhân viên', Icons.badge_rounded),
                _buildDrawerItem(NavigationTabs.bangTin, 'Bảng tin', Icons.newspaper_rounded),
                if (isBaoVe) _buildDrawerItem(NavigationTabs.phuongTien, 'Phương tiện', Icons.directions_car_rounded),
                _buildDrawerItem(NavigationTabs.tienIch, 'Tiện ích', Icons.sports_soccer_rounded),
                Consumer<SignalRService>(
                  builder: (_, signalR, _) => _buildDrawerItem(
                    NavigationTabs.datLichTienIch,
                    'Đặt lịch tiện ích',
                    Icons.event_note_rounded,
                    trailing: (signalR.unreadCounts['datLich'] ?? 0) > 0 ? _buildBadge(signalR.unreadCounts['datLich']!) : null,
                    onTapAction: () => signalR.clearUnreadFor('datLich'),
                  ),
                ),
                if (isQuanLy) _buildDrawerItem(NavigationTabs.nhatKyHeThong, 'Lịch sử hoạt động', Icons.history_rounded),
                Divider(color: AppColors.borderButton, height: 20, thickness: 1),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: AppColors.red),
                  title: Text(
                    'Đăng xuất',
                    style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close Drawer
                    _logout();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Urbano Manage v1.0',
              style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 11),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final String initial = _employeeName.isNotEmpty ? _employeeName[0].toUpperCase() : 'A';
    return DrawerHeader(
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        border: Border(
          bottom: BorderSide(color: AppColors.borderButton, width: 1),
        ),
      ),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          CircleAvatar(
            radius: 29.5,
            backgroundColor: AppColors.borderSide,
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.tealPrimary.withValues(alpha: 0.15),
              child: Text(
                initial,
                style: TextStyle(
                  color: AppColors.tealPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _employeeName.isNotEmpty ? _employeeName : 'Nhân viên',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _employeeCode.isNotEmpty ? 'Mã NV: $_employeeCode' : 'Ban quản lý',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon, {Widget? trailing, VoidCallback? onTapAction}) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.tealPrimary : AppColors.iconMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: trailing,
      selected: isSelected,
      selectedTileColor: AppColors.tealPrimary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      onTap: () {
        if (onTapAction != null) onTapAction();
        _onNavigate(index);
        Navigator.pop(context); // Close Drawer
      },
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.red,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 48, color: AppColors.tealPrimary),
          const SizedBox(height: 16),
          Text(
            'Đang phát triển',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tính năng này đang được xây dựng',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
