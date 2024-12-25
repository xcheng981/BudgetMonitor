import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/database/transaction_db.dart';
import '../services/shared/date_service.dart';

mixin TransactionStateMixin<T extends StatefulWidget> on State<T> {
  final TransactionDB transactionDB = TransactionDB();
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  DateTime get startDate => context.read<DateService>().startDate;
  DateTime get endDate => context.read<DateService>().endDate;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await transactionDB.getTransactions();
    if (mounted) {
      setState(() {
        _transactions = transactions..sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  void updateDateRange(DateTime start, DateTime end) {
    context.read<DateService>().setDateRange(start, end);
  }

  // Refresh transactions from the database
  Future<void> refreshTransactions() async {
    final transactions = await transactionDB.getTransactions();
    if (mounted) {
      setState(() {
        _transactions = transactions..sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  // Get transactions filtered by the current date range
  List<Transaction> get filteredTransactions {
    final dateService = context.watch<DateService>();
    return _transactions
        .where((t) => t.date.isAfter(dateService.startDate.subtract(Duration(days: 1))) && 
                      t.date.isBefore(dateService.endDate.add(Duration(days: 1))))
        .toList();
  }

  double get totalExpenses => filteredTransactions
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + t.amount.abs());

  double get totalIncome => filteredTransactions
      .where((t) => t.amount > 0)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  // Add a new transaction to the database
  Future<void> addTransaction(Transaction transaction) async {
    await transactionDB.addTransaction(transaction);
    await refreshTransactions();
  }

  // Update an existing transaction in the database
  Future<void> updateTransaction(Transaction transaction) async {
    await transactionDB.updateTransaction(transaction);
    await refreshTransactions();
  }

  // Delete a transaction from the database
  Future<void> deleteTransaction(Transaction transaction) async {
    await transactionDB.deleteTransaction(transaction);
    await refreshTransactions();
  }

  // Delete multiple transactions from the database
  Future<void> deleteTransactions(List<Transaction> transactions) async {
    for (final transaction in transactions) {
      await transactionDB.deleteTransaction(transaction);
    }
    await refreshTransactions();
  }
}