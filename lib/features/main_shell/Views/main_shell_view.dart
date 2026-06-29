import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/constants/navigation_tabs.dart';
import 'package:urbano_manage/Models/nhan_vien_model.dart';
import 'package:urbano_manage/features/auth/Views/login_view.dart';
import 'package:urbano_manage/features/dashboard/Views/dashboard_view.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/Views/yeu_cau_cu_dan_view.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_list_view.dart';
import 'package:urbano_manage/features/hoa_don/Views/hoa_don_list_view.dart';
import 'package:urbano_manage/features/thong_bao/Views/thong_bao_list_view.dart';
import 'package:urbano_manage/features/nhan_vien/Views/nhan_vien_list_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = NavigationTabs.dashboard;
  String _employeeName = '';
  String _employeeCode = '';

  @override
  void initState() {
    super.initState();
    _loadEmployeeInfo();
  }

  Future<void> _loadEmployeeInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nvStr = prefs.getString('nhanVien');
      if (nvStr != null) {
        final nvMap = jsonDecode(nvStr) as Map<String, dynamic>;
        final nv = NhanVien.fromJson(nvMap);
        setState(() {
          _employeeName = nv.hoTen;
          _employeeCode = nv.maNhanVien;
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
          title: const Text('Xác nhận đăng xuất', style: TextStyle(color: Colors.white)),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?', style: TextStyle(color: AppColors.textMuted)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('nhanVien');
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
    }

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
                child: const Icon(Icons.menu_rounded, size: 22, color: AppColors.tealPrimary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        DashboardView(onNavigate: _onNavigate),
        const CuDanListView(),
        const _PlaceholderPage(title: 'Căn hộ'),
        const HoaDonListView(),
        const _PlaceholderPage(title: 'Phí dịch vụ'),
        const YeuCauCuDanView(),
        const ThongBaoListView(),
        const NhanVienListView(),
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
                _buildDrawerItem(NavigationTabs.cuDan, 'Cư dân', Icons.people_alt_rounded),
                _buildDrawerItem(NavigationTabs.canHo, 'Căn hộ', Icons.apartment_rounded),
                _buildDrawerItem(NavigationTabs.hoaDon, 'Hóa đơn', Icons.receipt_long_rounded),
                _buildDrawerItem(NavigationTabs.phiDichVu, 'Phí dịch vụ', Icons.monetization_on_rounded),
                _buildDrawerItem(NavigationTabs.yeuCauCuDan, 'Yêu cầu cư dân', Icons.support_agent_rounded),
                _buildDrawerItem(NavigationTabs.thongBao, 'Thông báo', Icons.notifications_rounded),
                _buildDrawerItem(NavigationTabs.nhanVien, 'Nhân viên', Icons.badge_rounded),
                const Divider(color: AppColors.borderButton, height: 20, thickness: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.red),
                  title: const Text(
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
      decoration: const BoxDecoration(
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
                style: const TextStyle(
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _employeeCode.isNotEmpty ? 'Mã NV: $_employeeCode' : 'Ban quản lý',
                  style: const TextStyle(
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

  Widget _buildDrawerItem(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.tealPrimary : AppColors.iconMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.tealPrimary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      onTap: () {
        _onNavigate(index);
        Navigator.pop(context); // Close Drawer
      },
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
          const Icon(Icons.construction_rounded, size: 48, color: AppColors.tealPrimary),
          const SizedBox(height: 16),
          const Text(
            'Đang phát triển',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
