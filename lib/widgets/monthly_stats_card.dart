import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../screens/analysis_screen.dart'; 

class MonthlyStatsCard extends StatelessWidget {
  static String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  final String title;
  final Map<int, Map<String, double>> data;
  final Color color;

  const MonthlyStatsCard({
    super.key,
    required this.title,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>();

    double maxValue = 0.0;
    if (title == 'Detail') {  // Balance view
      final maxExpense = data.values
          .map((map) => map['expense'] ?? 0.0)
          .reduce((a, b) => a > b ? a : b);
      final maxIncome = data.values
          .map((map) => map['income'] ?? 0.0)
          .reduce((a, b) => a > b ? a : b);
      maxValue = maxExpense > maxIncome ? maxExpense : maxIncome;
    } else {
      maxValue = data.values.isEmpty
          ? 100.0
          : data.values
              .map((map) => map.values.reduce((a, b) => a + b))
              .reduce((a, b) => a > b ? a : b);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.9),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final amount = rod.toY;
                        if (title == 'Detail') {
                          final type = rodIndex == 0 ? "Expense: " : "Income: ";
                          return BarTooltipItem(
                            '$type${settings.formatAmount(amount)}',
                            const TextStyle(color: Colors.white),
                          );
                        }
                        return BarTooltipItem(
                          settings.formatAmount(amount),
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(_getMonthName(value.toInt())),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) =>
                            Text(settings.formatAmount(value)),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.entries.map((entry) {
                    if (title == 'Detail') {  // Balance view
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value['expense'] ?? 0,
                            color: Colors.red,
                            width: 12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: entry.value['income'] ?? 0,
                            color: Colors.green,
                            width: 12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    } else {  // Single view (expense or income)
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.values.first,
                            color: color,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}