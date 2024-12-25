import 'package:flutter/material.dart';
import 'dart:io';  
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/database/database_helper.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String type;
  final bool isCustomIcon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.isCustomIcon = false,
  });
  
  // Expense category
  static List<Category> expenseCategories = [
    Category(
      id: 'meal',
      name: 'Meal',
      icon: '🍜',
      type: 'expense',
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      type: 'expense',
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      icon: '🚌',
      type: 'expense',
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      type: 'expense',
    ),
    Category(
      id: 'housing',
      name: 'Housing',
      icon: '🏠',
      type: 'expense',
    ),
    Category(
      id: 'medical',
      name: 'Medical',
      icon: '🏥',
      type: 'expense',
    ),
    Category(
      id: 'game',
      name: 'Game',
      icon: '🎮',
      type: 'expense',
    ),
    Category(
      id: 'pet',
      name: 'Pet',
      icon: '🐈‍⬛',
      type: 'expense',
    ),
    Category(
      id: 'study',
      name: 'Study',
      icon: '📚',
      type: 'expense',
    ),
    Category(
      id: 'fruit',
      name: 'Fruits',
      icon: '🍉',
      type: 'expense',
    ),
    Category(
      id: 'vegetable',
      name: 'Vegetables',
      icon: '🥬',
      type: 'expense',
    ),

  ];

  // Income category
  static List<Category> incomeCategories = [
    Category(
      id: 'salary',
      name: 'Salary',
      icon: '💰',
      type: 'income',
    ),
    Category(
      id: 'bonus',
      name: 'Bonus',
      icon: '🎁',
      type: 'income',
    ),
    Category(
      id: 'part_time',
      name: 'Part-time',
      icon: '💼',
      type: 'income',
    ),
    Category(
      id: 'investment',
      name: 'Investment',
      icon: '📈',
      type: 'income',
    ),
  ];

  static const String _storageKey = 'custom_categories';

  // Fetch all categories (default + custom)
  static Future<List<Category>> getAllCategories() async {
    final dbHelper = DatabaseHelper();
    final customCategories = await dbHelper.getCustomCategories();
    
    // Convert custom categories from Map to Category objects
    final customCategoryObjects = customCategories.map((map) => Category.fromMap(map)).toList();
    
    // Combine default and custom categories
    final defaultCategories = [...expenseCategories, ...incomeCategories];
    final allCategories = List<Category>.from(defaultCategories);
    
    for (var customCategory in customCategoryObjects) {
      allCategories.removeWhere((category) => category.id == customCategory.id);
      allCategories.add(customCategory);
    }
    
    return allCategories;
  }

// Save a new custom category
static Future<void> saveCustomCategory(Category category) async {
    if (category.isCustomIcon) {
      final iconFile = File(category.icon);
      if (!await iconFile.exists()) {
        throw Exception('Icon file not found: ${category.icon}');
      }
    }
    
    final dbHelper = DatabaseHelper();
    await dbHelper.insertCategory(category.toMap());
  }

  static Future<void> updateCategory(Category category) async {
    if (category.isCustomIcon) {
      final iconFile = File(category.icon);
      if (!await iconFile.exists()) {
        throw Exception('Icon file not found: ${category.icon}');
      }
    }
    
    final dbHelper = DatabaseHelper();
    await dbHelper.updateCategory(category.id, category.toMap());
  }

// Delete a category and its custom icon if applicable
  static Future<void> deleteCategory(Category category) async {
    final dbHelper = DatabaseHelper();
    
    final isDefaultCategory = [...expenseCategories, ...incomeCategories]
        .any((c) => c.id == category.id);
        
    if (!isDefaultCategory) {
      await dbHelper.deleteCategory(category.id);
      // Delete custom icon file if it exists
      if (category.isCustomIcon) {
        try {
          final iconFile = File(category.icon);
          if (await iconFile.exists()) {
            await iconFile.delete();
          }
        } catch (e) {
          print('Error deleting category icon: $e');
        }
      }
    } else {
      throw Exception('Cannot delete default category');
    }
  }

  static List<Category> get allCategories => [...expenseCategories, ...incomeCategories];

  static Category? findById(String id) {
    try {
      return allCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Category> getCategoriesByType(String type) {
    return allCategories.where((category) => category.type == type).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'isCustomIcon': isCustomIcon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      type: map['type'],
      isCustomIcon: map['isCustomIcon'] ?? false,
    );
  }
}