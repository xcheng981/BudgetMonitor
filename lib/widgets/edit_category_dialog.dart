import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database/database_helper.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog({
    required this.category,
    Key? key,
  }) : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedIcon;
  final _dbHelper = DatabaseHelper();
  
  final List<String> _availableIcons = [
    '🍜', '🛍️', '🚌', '🎬', '🏠', '🏥', '🎮', '🐈‍⬛', '📚', '🍉', '🥬',  
    '💰', '🎁', '💼', '📈',  
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _deleteCategory() async {
    final isDefaultCategory = [...Category.expenseCategories, ...Category.incomeCategories]
        .any((c) => c.id == widget.category.id);
        
    if (isDefaultCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete default category')),
      );
      return;
    }

    final records = await _dbHelper.getRecordsByCategory(widget.category.id);
    
    if (records.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Warning'),
          content: Text(
            'This category has ${records.length} records. '
            'Deleting this category will also delete all related records. '
            'Do you want to continue?'
          ),
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

      if (confirmed != true) return;
    }

    await Category.deleteCategory(widget.category);
    Navigator.pop(context, 'deleted');  
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Category'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Name is required';
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Select Icon'),
              SizedBox(height: 8),
              Container(
                height: 200,
                width: 300,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon ? Colors.blue.withOpacity(0.1) : null,
                          border: Border.all(
                            color: _selectedIcon == icon ? Colors.blue : Colors.grey,
                            width: _selectedIcon == icon ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(icon, style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: _deleteCategory,
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text(
                  'Delete Category',
                  style: TextStyle(color: Colors.red),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final updatedCategory = Category(
                id: widget.category.id,
                name: _nameController.text,
                icon: _selectedIcon,
                type: widget.category.type,
                isCustomIcon: widget.category.isCustomIcon,
              );
              Navigator.pop(context, updatedCategory);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}