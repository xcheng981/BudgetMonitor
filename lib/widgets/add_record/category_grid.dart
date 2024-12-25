import 'package:flutter/material.dart';
import 'dart:io';  
import '../../models/category.dart';
import '../../screens/add_category_screen.dart';
import '../edit_category_dialog.dart';

class CategoryGrid extends StatefulWidget {
  final String type;
  final String? selectedCategoryId;
  final Function(Category) onSelect;

  const CategoryGrid({
    required this.type,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  _CategoryGridState createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didUpdateWidget(CategoryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    final allCategories = await Category.getAllCategories();
    setState(() {
      _categories = allCategories.where((c) => c.type == widget.type).toList();
    });
  }

  Color _getCategoryColor(Category category) {
    final colors = {
      'meal': Colors.orange.shade100,
      'shopping': Colors.pink.shade100,
      'transport': Colors.blue.shade100,
      'entertainment': Colors.purple.shade100,
      'housing': Colors.yellow.shade100,
      'medical': Colors.red.shade100,
      'game': Colors.indigo.shade100,      
      'pet': Colors.brown.shade100,       
      'study': Colors.cyan.shade100,       
      'fruit': Colors.green.shade100,     
      'vegetable': Colors.lightGreen.shade100,  
      
      'salary': Colors.green.shade100,
      'bonus': Colors.amber.shade100,
      'part_time': Colors.blue.shade100,
      'investment': Colors.teal.shade100,
      'rent': Colors.deepPurple.shade100,
      'dividend': Colors.indigo.shade100,
      'gift': Colors.pink.shade100,
    };

    return colors[category.id] ?? Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _categories.length + 1,
      itemBuilder: (context, index) {
        if (index == _categories.length) {
          return _buildAddCategoryButton(context);
        }
        return _buildCategoryItem(_categories[index]);
      },
    );
  }

  Widget _buildCategoryItem(Category category) {
    final isSelected = widget.selectedCategoryId == category.id;
    
    return GestureDetector(
      onTap: () => widget.onSelect(category),
      onLongPress: () async {
        final result = await showDialog<dynamic>(
          context: context,
          builder: (context) => EditCategoryDialog(category: category),
        );
        
        if (result == 'deleted') {
          await Category.deleteCategory(category);  
          await _loadCategories();
          if (isSelected) {
            widget.onSelect(Category(
              id: '',
              name: '',
              icon: '',
              type: widget.type,
            ));
          }
        } else if (result is Category) {  
          await Category.updateCategory(result);
          await _loadCategories();
          if (isSelected) {
            widget.onSelect(result);
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )]
                  : null,
            ),
            child: Center(
      child: category.isCustomIcon
          ? FutureBuilder<bool>(
              future: File(category.icon).exists(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return ClipOval(
                    child: Image.file(
                      File(category.icon),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, color: Colors.red);
                      },
                    ),
                  );
                }
                return Icon(Icons.broken_image, color: Colors.grey);
              },
            )
          : Text(
              category.icon,
              style: TextStyle(fontSize: 24),
            ),
    ),
          ),
          SizedBox(height: 8),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final newCategory = await Navigator.push<Category>(
          context,
          MaterialPageRoute(
            builder: (context) => AddCategoryScreen(type: widget.type),
          ),
        );
        
        if (newCategory != null) {
          await Category.saveCustomCategory(newCategory);
          await _loadCategories();
          widget.onSelect(newCategory);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 24,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add New',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}