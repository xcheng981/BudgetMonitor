import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';  
import '../models/user_settings.dart';  
import '../models/transaction.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/category_stats_card.dart'; 
import '../widgets/statistics_item.dart';
import '../widgets/monthly_stats_card.dart';     
import '../mixins/transaction_state_mixin.dart';
import 'package:intl/intl.dart';
import '../widgets/shared/bottom_nav_bar.dart';

enum ViewType { all, expense, income } // Enum to differentiate between expense, income, and balance views

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with TransactionStateMixin {
  ViewType _currentView = ViewType.all; // Keeps track of the currently selected view type

  // Get category-based statistics
  List<Map<String, dynamic>> getCategoryStats() {
    final Map<String, double> categoryTotals = {};
    final Map<String, String> categoryIcons = {};

    // Filter transactions based on the current view type
    var filteredByType = filteredTransactions;
    if (_currentView == ViewType.expense) {
      filteredByType = filteredByType.where((t) => t.amount < 0).toList();
    } else if (_currentView == ViewType.income) {
      filteredByType = filteredByType.where((t) => t.amount > 0).toList();
    }

    // Calculate total amount for each category
    for (var transaction in filteredByType) {
      categoryTotals[transaction.category.name] = 
          (categoryTotals[transaction.category.name] ?? 0) + transaction.amount.abs();
      categoryIcons[transaction.category.name] = transaction.category.icon;
    }

    // Prepare statistics with percentages
    final stats = categoryTotals.entries.map((entry) => {
      'category': entry.key,
      'amount': entry.value,
      'icon': categoryIcons[entry.key],
      'percentage': (entry.value / (_currentView == ViewType.expense ? totalExpenses : 
                    _currentView == ViewType.income ? totalIncome : 
                    (totalExpenses + totalIncome))) * 100,
    }).toList();

    stats.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double)); // Sort stats by amount
    return stats;
  }

  // Get monthly statistics for expenses, income, or balance
  Map<int, Map<String, double>> getMonthlyStats() {
    final Map<int, Map<String, double>> monthly = {};
  
    // Initialize data for the last 6 months
    for (int i = 0; i < 6; i++) {
      final month = endDate.month - i;
      final adjustedMonth = month > 0 ? month : month + 12;
      monthly[adjustedMonth] = {'expense': 0.0, 'income': 0.0};
    }

    // Populate statistics based on the view type
    for (var transaction in filteredTransactions) {
      final month = transaction.date.month;
      if (_currentView == ViewType.all) {
        if (transaction.amount < 0) {
          monthly[month]!['expense'] = (monthly[month]!['expense'] ?? 0) + transaction.amount.abs();
        } else {
          monthly[month]!['income'] = (monthly[month]!['income'] ?? 0) + transaction.amount;
        }
      } else if ((_currentView == ViewType.expense && transaction.amount < 0) ||
                 (_currentView == ViewType.income && transaction.amount > 0)) {
        monthly[month]!['expense'] = (monthly[month]!['expense'] ?? 0) + transaction.amount.abs();
      }
    }
    return monthly;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>();
    final categoryStats = getCategoryStats(); // Retrieve category stats
    final monthlyStats = getMonthlyStats(); // Retrieve monthly stats

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date range picker for filtering transactions
            DateRangePicker(
              startDate: startDate,
              endDate: endDate,
              onDateRangeSelected: updateDateRange,
            ),
            // Buttons to toggle between view types
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentView = ViewType.expense),
                      child: StatisticsItem(
                        label: 'Expenses',
                        amount: totalExpenses,
                        color: Colors.red,
                        isSelected: _currentView == ViewType.expense,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentView = ViewType.all),
                      child: StatisticsItem(
                        label: 'Balance',
                        amount: balance,
                        color: Colors.black,
                        isSelected: _currentView == ViewType.all,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentView = ViewType.income),
                      child: StatisticsItem(
                        label: 'Income',
                        amount: totalIncome,
                        color: Colors.green,
                        isSelected: _currentView == ViewType.income,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Display category stats card
            if (categoryStats.isNotEmpty) 
              CategoryStatsCard(
                title: _currentView == ViewType.expense ? 'Expense Category' :
                       _currentView == ViewType.income ? 'Income Category' : 'Category',
                stats: categoryStats,
                color: _currentView == ViewType.expense ? Colors.red :
                       _currentView == ViewType.income ? Colors.green : Colors.blue,
              ),
            // Display monthly stats card
            if (monthlyStats.isNotEmpty) 
              MonthlyStatsCard(
                title: _currentView == ViewType.expense ? 'Expense Detail' :
                       _currentView == ViewType.income ? 'Income Detail' : 'Detail',
                data: monthlyStats,
                color: _currentView == ViewType.expense ? Colors.red :
                       _currentView == ViewType.income ? Colors.green : Colors.blue,
              ),
            // Display transaction list
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                if ((_currentView == ViewType.expense && transaction.amount > 0) ||
                    (_currentView == ViewType.income && transaction.amount < 0)) {
                  return SizedBox.shrink();
                }
                return TransactionListItem(
                  transaction: transaction,
                  showMonthDivider: index == 0 || 
                    transaction.date.month != filteredTransactions[index - 1].date.month,
                  isSelectionMode: false,
                  isSelected: false,
                  onToggleSelect: () {},
                );
              },
            ),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/details');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
      ),
      // Floating action button to add a transaction
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_record') as Transaction?;
          if (result != null) {
            setState(() => refreshTransactions());
          }
        },
        child: Icon(Icons.add),
        backgroundColor: _currentView == ViewType.expense ? Colors.red :
                        _currentView == ViewType.income ? Colors.green : Colors.blue,
      ),
    );
  }
}
