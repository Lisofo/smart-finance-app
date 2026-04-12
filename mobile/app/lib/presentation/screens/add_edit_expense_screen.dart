import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/custom_button.dart';
import '../../core/constants/app_constants.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final int? expenseId;
  final String? initialDescription;
  final double? initialAmount;
  final String? initialCategory;
  final DateTime? initialExpenseDate;

  const AddEditExpenseScreen({
    super.key,
    this.expenseId,
    this.initialDescription,
    this.initialAmount,
    this.initialCategory,
    this.initialExpenseDate,
  });

  @override
  ConsumerState<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.initialDescription ?? '';
    _amountController.text = widget.initialAmount?.toString() ?? '';
    _selectedCategory = widget.initialCategory;
    _selectedDate = widget.initialExpenseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      if (isEditing) {
        await ref.read(expenseProvider.notifier).editExpense(
          id: widget.expenseId!,
          description: _descriptionController.text,
          amount: amount,
          category: _selectedCategory,
          expenseDate: _selectedDate,
        );
      } else {
        await ref.read(expenseProvider.notifier).addExpense(
          description: _descriptionController.text,
          amount: amount,
          category: _selectedCategory,
          expenseDate: _selectedDate,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Expense updated' : 'Expense added')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedCategory,
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...AppConstants.expenseCategories.map((cat) =>
                    DropdownMenuItem(value: cat, child: Text(cat))),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Expense Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _save,
                isLoading: expenseState.isLoading,
                text: isEditing ? 'Update' : 'Create',
              ),
            ],
          ),
        ),
      ),
    );
  }
}