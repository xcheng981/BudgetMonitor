import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  
import '../models/user_settings.dart';    

class StatisticsItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isSelected;

  const StatisticsItem({
    required this.label,
    required this.amount,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>(); 
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            settings.formatAmount(amount.abs()),  
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}