import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/add_record/add_record_form.dart';
import '../widgets/add_record/category_grid.dart';
import '../widgets/add_record/add_record_form.dart';
import '../services/database/transaction_db.dart'; 

class AddRecordScreen extends StatelessWidget {
  final TransactionDB transactionDB = TransactionDB();  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Record'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AddRecordForm(
            onSubmit: (transaction) async {
              await transactionDB.addTransaction(transaction);
              Navigator.pop(context, transaction);
            },
          ),
        ),
      ),
    );
  }
}