import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/expense_provider.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_surface_card.dart';
import '../widgets/app_text_field.dart';

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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit expense' : 'New expense'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Update the details below.' : 'Add an expense to your ledger.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'e.g. Groceries',
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.notes_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _amountController,
                labelText: 'Amount',
                hintText: '0.00',
                textInputAction: TextInputAction.next,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.attach_money_rounded),
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
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String?>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                hint: const Text('Optional'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...AppConstants.expenseCategories.map(
                    (cat) => DropdownMenuItem<String?>(
                      value: cat,
                      child: Text(cat),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                onTap: _pickDate,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md - 2,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: colorScheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat.yMMMMd().format(_selectedDate),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                onPressed: _save,
                isLoading: expenseState.isLoading,
                label: isEditing ? 'Save changes' : 'Add expense',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
