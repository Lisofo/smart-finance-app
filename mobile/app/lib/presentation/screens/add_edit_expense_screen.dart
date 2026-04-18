import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/category_styles.dart';
import '../providers/expense_provider.dart';
import '../widgets/app_error_banner.dart';
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
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  late DateTime _selectedDate;

  bool get isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseProvider.notifier).clearError();
    });
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
              description: _descriptionController.text.trim(),
              amount: amount,
              category: _selectedCategory,
              expenseDate: _selectedDate,
            );
      } else {
        await ref.read(expenseProvider.notifier).addExpense(
              description: _descriptionController.text.trim(),
              amount: amount,
              category: _selectedCategory,
              expenseDate: _selectedDate,
            );
      }
      if (!mounted) return;
      final err = ref.read(expenseProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err)),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Expense updated' : 'Expense added'),
        ),
      );
      context.pop();
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          child: child!,
        );
      },
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final paddingBottom = AppSpacing.xxl + bottomInset;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            isEditing ? 'Edit expense' : 'New expense',
            key: ValueKey(isEditing),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.md,
              AppSpacing.pageHorizontal,
              paddingBottom,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'Update the amount, category, or date. Changes save instantly.'
                              : 'Log a purchase in seconds. Category is optional but helps your charts.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
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
                    if (value == null || value.trim().isEmpty) {
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
                  textInputAction: TextInputAction.done,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    final n = double.parse(value);
                    if (n <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    if (n > 1e12) {
                      return 'Amount is too large';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Category',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tap to select — optional',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilterChip(
                      label: const Text('None'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                      },
                      showCheckmark: false,
                      selectedColor:
                          colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.85,
                      ),
                    ),
                    ...AppConstants.expenseCategories.map((cat) {
                      final selected = _selectedCategory == cat;
                      final c = CategoryStyles.colorFor(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                        },
                        selectedColor: c.withValues(alpha: 0.18),
                        checkmarkColor: c,
                        labelStyle: theme.textTheme.labelLarge?.copyWith(
                          color: selected
                              ? Color.lerp(c, const Color(0xFF0F172A), 0.2) ?? c
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: selected
                              ? c.withValues(alpha: 0.45)
                              : colorScheme.outlineVariant,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Date',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSurfaceCard(
                  onTap: _pickDate,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Icon(
                          Icons.event_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expense date',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.yMMMEd().format(_selectedDate),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.65),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: expenseState.error != null
                      ? Padding(
                          key: ValueKey(expenseState.error),
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppErrorBanner(message: expenseState.error!),
                        )
                      : const SizedBox(key: ValueKey('noerr'), height: 0),
                ),
                AppPrimaryButton(
                  onPressed: _save,
                  isLoading: expenseState.isLoading,
                  label: isEditing ? 'Save changes' : 'Add expense',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
