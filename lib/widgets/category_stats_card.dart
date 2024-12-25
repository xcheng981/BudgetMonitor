import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';

class CategoryStatsCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> stats;
  final Color color;
  final bool showBalanceColors;
  final bool showPercentage;

  const CategoryStatsCard({
    required this.title,
    required this.stats,
    this.color = Colors.blue,
    this.showBalanceColors = false,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>();  

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Column(
              children: stats.map((category) {
                final amount = category['amount'] as double;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                category['icon'] as String,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(category['category'] as String),
                          Spacer(),
                          if (showPercentage) ...[
                            Text(
                              '${(category['percentage'] as double).toStringAsFixed(1)}%',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(width: 16),
                          ],
                          Text(
                            settings.formatAmount(amount.abs()),  // 使用设置格式化金额
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (category['percentage'] as double) / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}