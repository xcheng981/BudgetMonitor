import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  
import '../models/user_settings.dart';    

class StatisticsCard extends StatelessWidget {
  final double expenses;
  final double income;
  final double balance;

  const StatisticsCard({
    required this.expenses,
    required this.income,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>();  
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Expenses', expenses.abs(), Colors.red, true),
          _buildStatItem(context, 'Balance', balance, Colors.black, false),
          _buildStatItem(context, 'Income', income, Colors.green, false),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, double amount, Color color, bool isExpense) {
    final settings = context.watch<UserSettings>();  
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color),
        ),
        Text(
          '${isExpense ? '-' : ''}${settings.formatAmount(amount)}',  
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}