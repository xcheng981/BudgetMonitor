import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../models/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool showMonthDivider;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionListItem({
    required this.transaction,
    this.showMonthDivider = false,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onToggleSelect,
    this.onEdit,
    this.onDelete,
  });

  void _showDeleteConfirmation(BuildContext context) {
    if (onDelete == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!.call();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>(); // Get user settings

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMonthDivider)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            width: double.infinity,
            child: Text(
              DateFormat('yyyy/MM').format(transaction.date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        InkWell(
          onLongPress: onToggleSelect,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: isSelectionMode
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelect(),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          transaction.category.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('MM/dd').format(transaction.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (transaction.title.isNotEmpty)
                    Text(
                      transaction.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${transaction.amount < 0 ? "-" : "+"}${settings.formatAmount(transaction.amount.abs())}',
                    style: TextStyle(
                      color: transaction.amount < 0 ? Colors.red[400] : Colors.green[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isSelectionMode) ...[
                    if (onEdit != null) ...[
                      SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: onEdit,
                      ),
                    ],
                    if (onDelete != null) ...[
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
