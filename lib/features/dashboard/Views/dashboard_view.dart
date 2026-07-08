import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/features/dashboard/ViewModels/dashboard_viewmodel.dart';
import 'package:urbano_manage/core/constants/navigation_tabs.dart';
import 'package:urbano_manage/Models/dashboard_models.dart';

class DashboardView extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardView({super.key, required this.onNavigate});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Material(
      type: MaterialType.transparency,
      child: RefreshIndicator(
        color: AppColors.tealPrimary,
        backgroundColor: AppColors.bgMid,
        onRefresh: () => viewModel.fetchDashboardData(),
        child: _buildContent(viewModel),
      ),
    );
  }

  Widget _buildContent(DashboardViewModel viewModel) {
    if (viewModel.isLoading && viewModel.statistics == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null && viewModel.statistics == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.error!,
                style: const TextStyle(color: AppColors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary),
                onPressed: () => viewModel.fetchDashboardData(),
                child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final stats = viewModel.statistics;
    final residentVal = stats != null ? stats.tongQuan.totalCuDan.toString() : '—';
    final apartmentVal = stats != null ? stats.tongQuan.totalCanHo.toString() : '—';
    final unpaidVal = stats != null ? stats.tongQuan.hoaDonChuaThanhToan.toString() : '—';
    final pendingVal = stats != null ? stats.tongQuan.yeuCauChoXuLy.toString() : '—';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 summary cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              _StatCard(
                title: 'Số cư dân',
                value: residentVal,
                icon: Icons.people_alt_rounded,
                color: AppColors.blue,
                onTap: () => widget.onNavigate(NavigationTabs.cuDan),
              ),
              _StatCard(
                title: 'Số căn hộ',
                value: apartmentVal,
                icon: Icons.apartment_rounded,
                color: AppColors.amber,
                onTap: () => widget.onNavigate(NavigationTabs.canHo),
              ),
              _StatCard(
                title: 'Hóa đơn chưa trả',
                value: unpaidVal,
                icon: Icons.receipt_long_rounded,
                color: AppColors.red,
                onTap: () => widget.onNavigate(NavigationTabs.hoaDon),
              ),
              _StatCard(
                title: 'Yêu cầu chờ xử lý',
                value: pendingVal,
                icon: Icons.pending_actions_rounded,
                color: AppColors.pink,
                onTap: () => widget.onNavigate(NavigationTabs.yeuCauCuDan),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Charts section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'BIỂU ĐỒ THỐNG KÊ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.tealPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          if (stats != null) ...[
            _buildRevenue6MonthsChartCard(stats),
            const SizedBox(height: 16),
            _buildRequestTypeChartCard(stats),
            const SizedBox(height: 24),
            
            // Warnings section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'CẢNH BÁO HỆ THỐNG',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildWarningCards(stats),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Format Y Axis helper
  String _formatYAxisValue(double value) {
    if (value == 0) return '0đ';
    if (value >= 1000000) {
      final double mil = value / 1000000;
      if (mil == mil.toInt().toDouble()) {
        return '${mil.toInt()}tr';
      } else {
        return '${mil.toStringAsFixed(1)}tr';
      }
    }
    return '${NumberFormat('#,###', 'vi_VN').format(value)}đ';
  }

  // 6 months revenue chart
  Widget _buildRevenue6MonthsChartCard(DashboardStatistics stats) {
    final list = stats.doanhThu6Thang;

    if (list.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: const Center(
          child: Text('Không có dữ liệu doanh thu', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    // Calculate maximum Y for scaling
    double maxY = 1000000;
    for (final item in list) {
      if (item.tongTien > maxY) maxY = item.tongTien;
      if (item.daThu > maxY) maxY = item.daThu;
    }
    maxY = maxY * 1.15; // 15% padding top

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu 6 tháng gần nhất',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              _buildLegendDot('Tổng tiền', AppColors.iconMuted),
              const SizedBox(width: 16),
              _buildLegendDot('Đã thu', AppColors.tealPrimary),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = list[groupIndex];
                      final isTotal = rodIndex == 0;
                      final label = isTotal ? 'Tổng tiền' : 'Đã thu';
                      final valStr = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(rod.toY);
                      return BarTooltipItem(
                        'Tháng ${item.thang}/${item.nam}\n$label: $valStr',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < list.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'T${list[index].thang}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            _formatYAxisValue(value),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(list.length, (index) {
                  final item = list[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.tongTien,
                        color: AppColors.iconMuted,
                        width: 10,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: item.daThu,
                        color: AppColors.tealPrimary,
                        width: 10,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  // PieChart for request by type
  Widget _buildRequestTypeChartCard(DashboardStatistics stats) {
    final list = stats.yeuCauTheoLoai;
    int totalRequests = 0;
    for (final item in list) {
      totalRequests += item.soLuong;
    }

    if (list.isEmpty || totalRequests == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text('Không có dữ liệu yêu cầu theo loại', style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
      );
    }

    // Colors mapping helper
    Color getSliceColor(int index) {
      final colors = [
        AppColors.tealPrimary,
        AppColors.blue,
        AppColors.amber,
        AppColors.pink,
        AppColors.red,
        Colors.purpleAccent,
        Colors.indigoAccent,
        Colors.orangeAccent,
      ];
      return colors[index % colors.length];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân loại Yêu cầu Cư dân',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 28,
                      sections: List.generate(list.length, (index) {
                        final item = list[index];
                        return PieChartSectionData(
                          value: item.soLuong.toDouble(),
                          color: getSliceColor(index),
                          title: '${item.soLuong}',
                          radius: 40,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(list.length, (index) {
                    final item = list[index];
                    final pct = (item.soLuong / totalRequests * 100).toStringAsFixed(1);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: getSliceColor(index), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.tenLoai}: ${item.soLuong} ($pct%)',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Warning Cards
  Widget _buildWarningCards(DashboardStatistics stats) {
    final cb = stats.canhBao;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _WarningCard(
            title: '${cb.hoaDonQuaHan} hóa đơn quá hạn thanh toán',
            subtitle: 'Bấm để đi đến Danh sách Hóa đơn',
            icon: Icons.warning_amber_rounded,
            backgroundColor: AppColors.red.withValues(alpha: 0.08),
            borderColor: AppColors.red.withValues(alpha: 0.3),
            iconColor: AppColors.red,
            onTap: () => widget.onNavigate(NavigationTabs.hoaDon),
          ),
          const SizedBox(height: 12),
          _WarningCard(
            title: '${cb.yeuCauQuaHan7Ngay} yêu cầu chờ xử lý > 7 ngày',
            subtitle: 'Bấm để đi đến Yêu cầu Cư dân',
            icon: Icons.hourglass_empty_rounded,
            backgroundColor: AppColors.amber.withValues(alpha: 0.08),
            borderColor: AppColors.amber.withValues(alpha: 0.3),
            iconColor: AppColors.amber,
            onTap: () => widget.onNavigate(NavigationTabs.yeuCauCuDan),
          ),
          const SizedBox(height: 12),
          _WarningCard(
            title: '${cb.canHoTrong} căn hộ chưa có cư dân',
            subtitle: 'Bấm để đi đến Quản lý Căn hộ',
            icon: Icons.meeting_room_rounded,
            backgroundColor: AppColors.blue.withValues(alpha: 0.08),
            borderColor: AppColors.blue.withValues(alpha: 0.3),
            iconColor: AppColors.blue,
            onTap: () => widget.onNavigate(NavigationTabs.canHo),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _WarningCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8), fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 14),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
