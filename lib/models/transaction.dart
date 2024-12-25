import 'dart:convert';
import 'category.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,  
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_name': category.name,
      'category_icon': category.icon,
      'category_type': category.type,
      'category_id': category.id,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'].toString(),  
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: Category(
        id: map['category_id'] as String,
        name: map['category_name'] as String,
        icon: map['category_icon'] as String,
        type: map['category_type'] as String,
      ),
    );
  }
}