import 'package:flutter/material.dart';

class AddRecordFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AddRecordFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(Icons.add),
      backgroundColor: Colors.teal,
    );
  }
}