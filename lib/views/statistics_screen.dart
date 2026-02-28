import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  static const List<Color> _chartColors = [
    Color(0xFFFF6384),
    Color(0xFF36A2EB),
    Color(0xFFFFCE56),
    Color(0xFF4BC0C0),
    Color(0xFF9966FF),
    Color(0xFFFF9F40),
    Color(0xFFC9CBCF),
    Color(0xFF7BC043),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final expenseMap = ref.watch(monthlyExpenseByCategoryProvider);
    final dailyMap = ref.watch(dailyExpenseProvider);

    final monthName =
        DateFormat('MMMM yyyy', 'vi').format(selectedMonth);

    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chi tiêu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Month picker ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final m = ref.read(selectedMonthProvider);
                    ref.read(selectedMonthProvider.notifier).state =
                        DateTime(m.year, m.month - 1);
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedMonth,
                      firstDate: DateTime(2020),
                      lastDate: now,
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                    );
                    if (picked != null) {
                      ref.read(selectedMonthProvider.notifier).state =
                          DateTime(picked.year, picked.month);
                    }
                  },
                  child: Text(
                    monthName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final m = ref.read(selectedMonthProvider);
                    final next = DateTime(m.year, m.month + 1);
                    if (!next.isAfter(DateTime.now())) {
                      ref.read(selectedMonthProvider.notifier).state = next;
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Empty state ───────────────────────────────
            if (expenseMap.isEmpty) ...[
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.pie_chart_outline,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('Chưa có dữ liệu chi tiêu',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text('trong $monthName',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ] else ...[
              // ── Summary ─────────────────────────────────
              Builder(builder: (_) {
                final total =
                    expenseMap.values.fold(0.0, (a, b) => a + b);
                final entries = expenseMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiêu tháng ${DateFormat('MM/yyyy').format(selectedMonth)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng: ${currencyFormat.format(total)}',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),

                    // ── Pie Chart with tooltip ────────────
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            enabled: true,
                            touchCallback: (event, response) {},
                          ),
                          sections:
                              entries.asMap().entries.map((entry) {
                            final i = entry.key;
                            final e = entry.value;
                            final pct = e.value / total * 100;
                            return PieChartSectionData(
                              color:
                                  _chartColors[i % _chartColors.length],
                              value: e.value,
                              title: '${pct.toStringAsFixed(1)}%',
                              radius: 100,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              titlePositionPercentageOffset: 0.6,
                              badgeWidget: null,
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Legend ─────────────────────────────
                    const Text('Chi tiết theo danh mục',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...entries.asMap().entries.map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      final pct = e.value / total * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _chartColors[
                                    i % _chartColors.length],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(e.key,
                                    style:
                                        const TextStyle(fontSize: 14))),
                            Text(
                              currencyFormat.format(e.value),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 50,
                              child: Text(
                                '${pct.toStringAsFixed(1)}%',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // ── Daily bar chart (bonus) ─────────────────
              if (dailyMap.isNotEmpty) ...[
                const Text('Chi tiêu theo ngày',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: dailyMap.values.fold(0.0,
                              (a, b) => a > b ? a : b) *
                          1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, gIdx, rod, rIdx) {
                            return BarTooltipItem(
                              currencyFormat.format(rod.toY),
                              const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: dailyMap.entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value,
                              color: Theme.of(context).colorScheme.primary,
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList()
                        ..sort((a, b) => a.x.compareTo(b.x)),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
