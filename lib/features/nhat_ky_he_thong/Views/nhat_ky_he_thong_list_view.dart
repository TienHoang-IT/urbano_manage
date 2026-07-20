import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/Models/nhat_ky_he_thong_model.dart';
import 'package:urbano_manage/features/nhat_ky_he_thong/ViewModels/nhat_ky_he_thong_viewmodel.dart';

class NhatKyHeThongListView extends StatefulWidget {
  const NhatKyHeThongListView({super.key});

  @override
  State<NhatKyHeThongListView> createState() => _NhatKyHeThongListViewState();
}

class _NhatKyHeThongListViewState extends State<NhatKyHeThongListView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTable;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, String>> _tables = const [
    {'value': 'CanHo', 'label': 'Căn hộ'},
    {'value': 'CuDan', 'label': 'Cư dân'},
    {'value': 'HoaDon', 'label': 'Hóa đơn'},
    {'value': 'PhuongTien', 'label': 'Phương tiện'},
    {'value': 'YeuCauCuDan', 'label': 'Yêu cầu'},
    {'value': 'NhanVien', 'label': 'Nhân viên'},
    {'value': 'ThongBao', 'label': 'Thông báo'},
    {'value': 'BangTin', 'label': 'Bảng tin'},
    {'value': 'PhiDichVu', 'label': 'Phí dịch vụ'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NhatKyHeThongViewModel>().fetchLogs(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final vm = context.read<NhatKyHeThongViewModel>();
      if (!vm.isLoadMore && !vm.isLoading) {
        vm.fetchLogs(refresh: false);
      }
    }
  }

  void _applyFilters() {
    context.read<NhatKyHeThongViewModel>().updateFilters(
          bangTacDong: _selectedTable,
          from: _startDate,
          to: _endDate,
          search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        );
  }

  void _clearFilters() {
    setState(() {
      _selectedTable = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
    context.read<NhatKyHeThongViewModel>().clearFilters();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: _datePickerTheme,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _applyFilters();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: _datePickerTheme,
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _applyFilters();
    }
  }

  Theme _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: AppColors.tealPrimary,
          onPrimary: AppColors.textPrimary,
          surface: AppColors.bgMid,
          onSurface: AppColors.textPrimary,
        ), dialogTheme: DialogThemeData(backgroundColor: AppColors.bgDark),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NhatKyHeThongViewModel>();

    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          _buildFilterBar(viewModel),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.tealPrimary,
              backgroundColor: AppColors.bgMid,
              onRefresh: () => viewModel.fetchLogs(refresh: true),
              child: _buildLogList(viewModel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(NhatKyHeThongViewModel viewModel) {
    final df = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.bgDark,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo hành động...',
                    hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.iconMuted, size: 18),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderButton),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderButton),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderSide),
                    ),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _selectedTable,
                dropdownColor: AppColors.bgMid,
                hint: Text('Bảng', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                underline: const SizedBox.shrink(),
                icon: Icon(Icons.arrow_drop_down, color: AppColors.tealPrimary),
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Tất cả bảng')),
                  ..._tables.map((t) => DropdownMenuItem<String>(value: t['value'], child: Text(t['label']!))),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedTable = val;
                  });
                  _applyFilters();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _selectStartDate,
                    icon: Icon(Icons.date_range_rounded, size: 14, color: AppColors.tealPrimary),
                    label: Text(
                      _startDate == null ? 'Từ ngày' : df.format(_startDate!),
                      style: TextStyle(fontSize: 11, color: AppColors.textPrimary70),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: BorderSide(color: AppColors.borderButton),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _selectEndDate,
                    icon: Icon(Icons.date_range_rounded, size: 14, color: AppColors.tealPrimary),
                    label: Text(
                      _endDate == null ? 'Đến ngày' : df.format(_endDate!),
                      style: TextStyle(fontSize: 11, color: AppColors.textPrimary70),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: BorderSide(color: AppColors.borderButton),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              if (_selectedTable != null || _startDate != null || _endDate != null || _searchController.text.isNotEmpty)
                TextButton(
                  onPressed: _clearFilters,
                  child: Text('Xóa lọc', style: TextStyle(color: AppColors.red, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(NhatKyHeThongViewModel viewModel) {
    if (viewModel.isLoading && viewModel.logs.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.tealPrimary));
    }

    if (viewModel.error != null && viewModel.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.error!, style: TextStyle(color: AppColors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary),
              onPressed: () => viewModel.fetchLogs(refresh: true),
              child: Text('Thử lại', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      );
    }

    if (viewModel.logs.isEmpty) {
      return Center(
        child: Text('Không có nhật ký nào', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    final tf = DateFormat('dd/MM/yyyy HH:mm:ss');

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: viewModel.logs.length + 1,
      itemBuilder: (context, index) {
        if (index == viewModel.logs.length) {
          return viewModel.isLoadMore
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.tealPrimary)),
                )
              : const SizedBox.shrink();
        }

        final log = viewModel.logs[index];

        return Card(
          color: AppColors.nenContainer,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.borderButton),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    log.hanhDong,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Text(
                  tf.format(log.thoiGian.toLocal()),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: AppColors.iconMuted, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      log.tenNguoiThucHien.isNotEmpty ? log.tenNguoiThucHien : 'Hệ thống',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(width: 14),
                    Icon(Icons.table_rows_rounded, color: AppColors.iconMuted, size: 14),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.bangTacDong,
                        style: TextStyle(color: AppColors.tealPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (log.idBanGhi != null) ...[
                  const SizedBox(height: 4),
                  Text('ID Bản ghi: ${log.idBanGhi}', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ]
              ],
            ),
            trailing: Icon(Icons.arrow_right_rounded, color: AppColors.iconMuted),
            onTap: () => _showLogDetail(log),
          ),
        );
      },
    );
  }

  void _showLogDetail(NhatKyHeThong log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    log.hanhDong,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: AppColors.borderButton),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Người thực hiện', log.tenNguoiThucHien.isNotEmpty ? log.tenNguoiThucHien : 'Hệ thống'),
                      _buildDetailRow('Thời gian', DateFormat('dd/MM/yyyy HH:mm:ss').format(log.thoiGian.toLocal())),
                      _buildDetailRow('Bảng tác động', log.bangTacDong),
                      if (log.idBanGhi != null) _buildDetailRow('ID Bản ghi', log.idBanGhi.toString()),
                      const SizedBox(height: 16),
                      Text('Giá trị cũ:', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: Text(
                          log.giaTriCu != null && log.giaTriCu!.isNotEmpty ? log.giaTriCu! : 'Không có dữ liệu',
                          style: TextStyle(color: log.giaTriCu != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Giá trị mới:', style: TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: Text(
                          log.giaTriMoi != null && log.giaTriMoi!.isNotEmpty ? log.giaTriMoi! : 'Không có dữ liệu',
                          style: TextStyle(color: log.giaTriMoi != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
