import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import 'category_grid.dart';
import 'package:intl/intl.dart';

class AddRecordForm extends StatefulWidget {
  final Transaction? initialTransaction;
  final void Function(Transaction)? onSubmit;

  const AddRecordForm({
    this.initialTransaction,
    this.onSubmit,  
    Key? key,
  }) : super(key: key);

  @override
  _AddRecordFormState createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String? _selectedCategoryId;
  late double? _amount;
  late String _description;
  late DateTime _selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _type = 'expense';
    _selectedCategoryId = null;
    _amount = null;
    _description = '';
    _selectedDate = DateTime.now();

    if (widget.initialTransaction != null) {
      _type = widget.initialTransaction!.amount < 0 ? 'expense' : 'income';
      _selectedCategoryId = widget.initialTransaction!.category.id;
      _amount = widget.initialTransaction!.amount.abs();
      _description = widget.initialTransaction!.title;
      _selectedDate = widget.initialTransaction!.date;
    }

    _amountController = TextEditingController(
      text: _amount?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: _description,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
  if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
    final selectedCategory = Category.findById(_selectedCategoryId!);
    if (selectedCategory != null) {
      final formattedAmount = (_amount ?? 0).toStringAsFixed(2);
      final transaction = Transaction(
        id: widget.initialTransaction?.id ?? 
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _description.isEmpty ? selectedCategory.name : _description,
        amount: _type == 'expense' 
            ? -double.parse(formattedAmount)
            : double.parse(formattedAmount),
        date: _selectedDate,
        category: selectedCategory,
      );
      
      if (widget.onSubmit != null) {
        widget.onSubmit!(transaction);
      } else {
        Navigator.pop(context, transaction);
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Type Selector (Expense/Income)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _type = 'expense'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _type == 'expense' ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Expense',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _type == 'expense' ? Colors.black : Colors.grey,
                        fontWeight: _type == 'expense' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _type = 'income'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _type == 'income' ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Income',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _type == 'income' ? Colors.black : Colors.grey,
                        fontWeight: _type == 'income' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'CHOOSE CATEGORY ICON',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 16),
          CategoryGrid(
            type: _type,
            selectedCategoryId: _selectedCategoryId,
            onSelect: (category) {
              setState(() {
                _selectedCategoryId = category.id;
              });
            },
          ),
          SizedBox(height: 24),
          // Date Picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Date',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            subtitle: Text(
              DateFormat('yyyy-MM-dd').format(_selectedDate),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
            ),
          ),
          SizedBox(height: 16),
          // Amount Input
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onChanged: (value) {
              _amount = double.tryParse(value);
            },
          ),
          SizedBox(height: 16),
          // Description Input
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Description (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _description = value;
            },
          ),
          SizedBox(height: 24),
          // Submit Button
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.initialTransaction != null ? 'Update' : 'Add new ${_type}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}