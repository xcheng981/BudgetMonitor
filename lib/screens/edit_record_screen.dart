import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/add_record/add_record_form.dart';

class EditRecordScreen extends StatelessWidget {
  final Transaction transaction;

  const EditRecordScreen({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Record'),
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
            initialTransaction: transaction,
          ),
        ),
      ),
    );
  }
}