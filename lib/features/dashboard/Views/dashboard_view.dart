import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/features/dashboard/ViewModels/dashboard_viewmodel.dart';
import 'package:urbano_manage/core/constants/navigation_tabs.dart';

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
    if (viewModel.isLoading &&
        viewModel.residentCount == null &&
        viewModel.unpaidBillCount == null &&
        viewModel.pendingRequestCount == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (viewModel.error != null &&
        viewModel.residentCount == null &&
        viewModel.unpaidBillCount == null &&
        viewModel.pendingRequestCount == null) {
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

    final residentVal = viewModel.residentCount != null ? viewModel.residentCount.toString() : '—';
    final apartmentVal = viewModel.apartmentCount != null ? viewModel.apartmentCount.toString() : '—';
    final unpaidVal = viewModel.unpaidBillCount != null ? viewModel.unpaidBillCount.toString() : '—';
    final pendingVal = viewModel.pendingRequestCount != null ? viewModel.pendingRequestCount.toString() : '—';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          _buildRevenueChartCard(viewModel),
          const SizedBox(height: 16),
          _buildRequestRatioChartCard(viewModel),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRevenueChartCard(DashboardViewModel vm) {
    final currencyFormat = NumberFormat.compact(locale: 'vi_VN');
    final total = vm.revenueTotal;
    final paid = vm.revenuePaid;
    final unpaid = vm.revenueUnpaid;

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
            'Thống kê Doanh thu Hóa đơn',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: total > 0 ? total * 1.15 : 10000000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.bgMid,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label;
                      switch (group.x) {
                        case 0:
                          label = 'Tổng';
                          break;
                        case 1:
                          label = 'Đã thu';
                          break;
                        default:
                          label = 'Chưa thu';
                      }
                      final valStr = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(rod.toY);
                      return BarTooltipItem(
                        '$label\n$valStr',
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
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = 'Tổng';
                            break;
                          case 1:
                            text = 'Đã thu';
                            break;
                          case 2:
                            text = 'Chưa thu';
                            break;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          currencyFormat.format(value),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
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
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        color: AppColors.tealPrimary,
                        width: 22,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      )
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: paid,
                        color: AppColors.blue,
                        width: 22,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      )
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: unpaid,
                        color: AppColors.red,
                        width: 22,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestRatioChartCard(DashboardViewModel vm) {
    final pending = vm.reqPendingCount;
    final inProgress = vm.reqInProgressCount;
    final completed = vm.reqCompletedCount;
    final rejected = vm.reqRejectedCount;
    final total = pending + inProgress + completed + rejected;

    if (total == 0) {
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
            child: Text('Không có dữ liệu yêu cầu', style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
      );
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
            'Trạng thái Yêu cầu Cư dân',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(
                          value: pending.toDouble(),
                          color: AppColors.pink,
                          title: pending > 0 ? '$pending' : '',
                          radius: 40,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          value: inProgress.toDouble(),
                          color: AppColors.amber,
                          title: inProgress > 0 ? '$inProgress' : '',
                          radius: 40,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          value: completed.toDouble(),
                          color: AppColors.tealPrimary,
                          title: completed > 0 ? '$completed' : '',
                          radius: 40,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          value: rejected.toDouble(),
                          color: AppColors.red,
                          title: rejected > 0 ? '$rejected' : '',
                          radius: 40,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Chờ xử lý', AppColors.pink, pending, total),
                    const SizedBox(height: 6),
                    _buildLegendItem('Đang xử lý', AppColors.amber, inProgress, total),
                    const SizedBox(height: 6),
                    _buildLegendItem('Hoàn thành', AppColors.tealPrimary, completed, total),
                    const SizedBox(height: 6),
                    _buildLegendItem('Từ chối', AppColors.red, rejected, total),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, int total) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $count ($pct%)',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
