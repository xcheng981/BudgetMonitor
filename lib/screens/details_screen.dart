import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../models/transaction.dart';
import '../widgets/statistics_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/date_range_picker.dart';
import '../services/database/transaction_db.dart';
import '../screens/add_record_screen.dart';
import '../screens/edit_record_screen.dart';
import '../mixins/transaction_state_mixin.dart';
import '../widgets/shared/bottom_nav_bar.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with TransactionStateMixin {
  bool _isSelectionMode = false; // Flag to check if selection mode is active
  Set<String> _selectedIds = {}; // Stores IDs of selected transactions

  // Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear(); // Clear selection when toggling mode
    });
  }

  // Add or remove a transaction ID from the selection
  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false; // Exit selection mode if no items are selected
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // Delete selected transactions
  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${_selectedIds.length} selected records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    // If confirmed, delete selected transactions
    if (confirmed == true) {
      for (final id in _selectedIds) {
        final transaction = transactions.firstWhere((t) => t.id == id);
        await transactionDB.deleteTransaction(transaction);
      }
      _selectedIds.clear();
      _isSelectionMode = false;
      await refreshTransactions();
    }
  }

  // Add a new transaction
  void _addNewRecord() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => AddRecordScreen()),
    );
    if (result != null) {
      await refreshTransactions();
    }
  }

  // Edit an existing transaction
  void _editRecord(Transaction transaction) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecordScreen(transaction: transaction),
      ),
    );
    if (result != null) {
      await transactionDB.updateTransaction(result); // Update transaction in the database
      await refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>(); // Watch user settings for updates
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _deleteSelected,
              child: Text(
                'Delete (${_selectedIds.length})',
                style: TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _toggleSelectionMode,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Date range picker
          DateRangePicker(
            startDate: startDate,
            endDate: endDate,
            onDateRangeSelected: updateDateRange,
          ),
          // Display summary of expenses, income, and balance
          StatisticsCard(
            expenses: totalExpenses,
            income: totalIncome,
            balance: balance,
          ),
          // List of transactions
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Text(
                      'No records in selected date range',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      final showMonthDivider = index == 0 || 
                        transaction.date.month != filteredTransactions[index - 1].date.month;
                      
                      return TransactionListItem(
                        transaction: transaction,
                        showMonthDivider: showMonthDivider, // Show month divider if the month changes
                        isSelectionMode: _isSelectionMode,
                        isSelected: _selectedIds.contains(transaction.id),
                        onToggleSelect: () {
                          if (!_isSelectionMode) {
                            _toggleSelectionMode();
                          }
                          _toggleSelect(transaction.id);
                        },
                        onDelete: () async {
                          await transactionDB.deleteTransaction(transaction);
                          await refreshTransactions();
                        },
                        onEdit: () => _editRecord(transaction),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecord,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // Bottom navigation bar for screen navigation
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/analysis');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
      ),
    );
  }
}
