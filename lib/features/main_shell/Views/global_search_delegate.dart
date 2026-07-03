import 'dart:async';
import 'package:flutter/material.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/global_search_model.dart';
import 'package:urbano_manage/Services/tim_kiem_service.dart';
import 'package:urbano_manage/Services/can_ho_service.dart';
import 'package:urbano_manage/Services/cu_dan_service.dart';
import 'package:urbano_manage/Services/hoa_don_service.dart';
import 'package:urbano_manage/Services/phuong_tien_service.dart';
import 'package:urbano_manage/features/can_ho/Views/can_ho_detail_view.dart';
import 'package:urbano_manage/features/cu_dan/Views/cu_dan_detail_view.dart';
import 'package:urbano_manage/features/hoa_don/Views/hoa_don_detail_view.dart';
import 'package:urbano_manage/features/phuong_tien/Views/phuong_tien_detail_view.dart';

class GlobalSearchDelegate extends SearchDelegate<dynamic> {
  final TimKiemService _searchService = TimKiemService();
  final CanHoService _canHoService = CanHoService();
  final CuDanService _cuDanService = CuDanService();
  final HoaDonService _hoaDonService = HoaDonService();
  final PhuongTienService _phuongTienService = PhuongTienService();

  GlobalSearchDelegate()
      : super(
          searchFieldLabel: 'Tìm kiếm toàn cục...',
          searchFieldStyle: const TextStyle(color: Colors.white, fontSize: 16),
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.tealPrimary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textHint),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.tealPrimary),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchContent(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchContent(context);
  }

  Widget _buildSearchContent(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(
        color: AppColors.bgDark,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, size: 48, color: AppColors.tealPrimary),
              SizedBox(height: 12),
              Text(
                'Nhập từ khóa để tìm kiếm...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.bgDark,
      child: SearchSuggestionsView(
        query: query.trim(),
        searchService: _searchService,
        onSelectCanHo: (item) => _navigateCanHo(context, item),
        onSelectCuDan: (item) => _navigateCuDan(context, item),
        onSelectHoaDon: (item) => _navigateHoaDon(context, item),
        onSelectPhuongTien: (item) => _navigatePhuongTien(context, item),
      ),
    );
  }

  // Helper methods to load full details and push to Views
  Future<void> _navigateCanHo(BuildContext context, SearchCanHo item) async {
    _showLoadingDialog(context);
    try {
      final detail = await _canHoService.fetchCanHoById(item.id);
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CanHoDetailView(canHo: detail)),
      );
    } catch (e) {
      _handleNavError(context, e);
    }
  }

  Future<void> _navigateCuDan(BuildContext context, SearchCuDan item) async {
    _showLoadingDialog(context);
    try {
      final detail = await _cuDanService.fetchCuDanById(item.id);
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CuDanDetailView(cuDan: detail)),
      );
    } catch (e) {
      _handleNavError(context, e);
    }
  }

  Future<void> _navigateHoaDon(BuildContext context, SearchHoaDon item) async {
    _showLoadingDialog(context);
    try {
      final detail = await _hoaDonService.fetchHoaDonById(item.id);
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HoaDonDetailView(hoaDon: detail)),
      );
    } catch (e) {
      _handleNavError(context, e);
    }
  }

  Future<void> _navigatePhuongTien(BuildContext context, SearchPhuongTien item) async {
    _showLoadingDialog(context);
    try {
      final detail = await _phuongTienService.fetchById(item.id);
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PhuongTienDetailView(phuongTien: detail)),
      );
    } catch (e) {
      _handleNavError(context, e);
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      ),
    );
  }

  void _handleNavError(BuildContext context, dynamic e) {
    if (context.mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải chi tiết: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class SearchSuggestionsView extends StatefulWidget {
  final String query;
  final TimKiemService searchService;
  final ValueChanged<SearchCanHo> onSelectCanHo;
  final ValueChanged<SearchCuDan> onSelectCuDan;
  final ValueChanged<SearchHoaDon> onSelectHoaDon;
  final ValueChanged<SearchPhuongTien> onSelectPhuongTien;

  const SearchSuggestionsView({
    super.key,
    required this.query,
    required this.searchService,
    required this.onSelectCanHo,
    required this.onSelectCuDan,
    required this.onSelectHoaDon,
    required this.onSelectPhuongTien,
  });

  @override
  State<SearchSuggestionsView> createState() => _SearchSuggestionsViewState();
}

class _SearchSuggestionsViewState extends State<SearchSuggestionsView> {
  Timer? _debounceTimer;
  bool _isLoading = false;
  String? _error;
  GlobalSearchData? _results;

  @override
  void initState() {
    super.initState();
    _startSearchTimer();
  }

  @override
  void didUpdateWidget(covariant SearchSuggestionsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      _startSearchTimer();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startSearchTimer() {
    _debounceTimer?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final data = await widget.searchService.search(widget.query);
        if (mounted) {
          setState(() {
            _results = data;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e.toString().replaceFirst('Exception: ', '');
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.tealPrimary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_error!, style: const TextStyle(color: AppColors.red), textAlign: TextAlign.center),
        ),
      );
    }

    if (_results == null) {
      return const SizedBox.shrink();
    }

    final res = _results!;
    final total = res.canHo.length + res.cuDan.length + res.hoaDon.length + res.phuongTien.length;

    if (total == 0) {
      return const Center(
        child: Text('Không tìm thấy kết quả nào', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (res.canHo.isNotEmpty) ...[
          _buildHeader('Căn hộ', res.canHo.length, Icons.apartment_rounded),
          ...res.canHo.map((c) => _buildItemCard(
                title: 'Căn hộ ${c.soCanHo}',
                subtitle: c.tenToaNha,
                icon: Icons.meeting_room_rounded,
                onTap: () => widget.onSelectCanHo(c),
              )),
          const SizedBox(height: 16),
        ],
        if (res.cuDan.isNotEmpty) ...[
          _buildHeader('Cư dân', res.cuDan.length, Icons.people_alt_rounded),
          ...res.cuDan.map((c) => _buildItemCard(
                title: c.hoTen,
                subtitle: c.soCanHo.isNotEmpty ? 'Căn hộ: ${c.soCanHo}' : 'Chưa gán căn hộ',
                icon: Icons.person_rounded,
                onTap: () => widget.onSelectCuDan(c),
              )),
          const SizedBox(height: 16),
        ],
        if (res.hoaDon.isNotEmpty) ...[
          _buildHeader('Hóa đơn', res.hoaDon.length, Icons.receipt_long_rounded),
          ...res.hoaDon.map((h) => _buildItemCard(
                title: h.maThanhToan,
                subtitle: 'Căn hộ: ${h.soCanHo}',
                icon: Icons.receipt_rounded,
                onTap: () => widget.onSelectHoaDon(h),
              )),
          const SizedBox(height: 16),
        ],
        if (res.phuongTien.isNotEmpty) ...[
          _buildHeader('Phương tiện', res.phuongTien.length, Icons.directions_car_rounded),
          ...res.phuongTien.map((p) => _buildItemCard(
                title: p.bienSo,
                subtitle: 'Căn hộ: ${p.soCanHo}',
                icon: Icons.drive_eta_rounded,
                onTap: () => widget.onSelectPhuongTien(p),
              )),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildHeader(String label, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.tealPrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$label ($count)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.nenContainer,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.borderButton),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: AppColors.textMuted, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
        onTap: onTap,
      ),
    );
  }
}
