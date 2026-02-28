import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/transaction_viewmodel.dart';

class StatisticsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'vi').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chi tiêu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, vm, _) {
          final expenseMap = vm.expenseByCategory;

          if (expenseMap.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có dữ liệu chi tiêu',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'trong $monthName',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final total = expenseMap.values.fold(0.0, (a, b) => a + b);
          final entries = expenseMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final currencyFormat = NumberFormat.currency(
            locale: 'vi_VN',
            symbol: 'đ',
            decimalDigits: 0,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month header
                Text(
                  'Chi tiêu tháng ${DateFormat('MM/yyyy').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng: ${currencyFormat.format(total)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 24),

                // Pie Chart
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: entries.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final percentage = (e.value / total * 100);
                        return PieChartSectionData(
                          color: _chartColors[i % _chartColors.length],
                          value: e.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          titlePositionPercentageOffset: 0.6,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Legend
                const Text(
                  'Chi tiết theo danh mục',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final percentage = (e.value / total * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _chartColors[i % _chartColors.length],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          currencyFormat.format(e.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 50,
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
