import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/feedback_states.dart';
import '../../core/constants/app_constants.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _hasFilters =>
      _selectedCategory != null || _startDate != null || _endDate != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseProvider.notifier).loadExpenses();
    });
  }

  void _applyFilters() {
    ref.read(expenseProvider.notifier).updateFilters(
          ExpenseFilters(
            category: _selectedCategory,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
    ref.read(expenseProvider.notifier).updateFilters(ExpenseFilters());
    Navigator.pop(context);
  }

  void _resetFiltersFromBar() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
    ref.read(expenseProvider.notifier).updateFilters(ExpenseFilters());
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Filter expenses',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _selectedCategory,
                          hint: const Text('All categories'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All categories'),
                            ),
                            ...AppConstants.expenseCategories.map(
                              (cat) => DropdownMenuItem<String?>(
                                value: cat,
                                child: Text(cat),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setStateDialog(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      title: Text(
                        _startDate == null
                            ? 'Start date'
                            : 'From ${DateFormat.yMMMd().format(_startDate!)}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      trailing: Icon(Icons.event_outlined,
                          color: colorScheme.primary),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            _startDate = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      title: Text(
                        _endDate == null
                            ? 'End date'
                            : 'To ${DateFormat.yMMMd().format(_endDate!)}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      trailing: Icon(Icons.event_outlined,
                          color: colorScheme.primary),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            _endDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear all'),
            ),
            FilledButton(
              onPressed: _applyFilters,
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              expenseState.expenses.isEmpty
                  ? 'Track spending in one place'
                  : '${expenseState.expenses.length} recorded',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Icon(
              Icons.tune_rounded,
              color: _hasFilters ? colorScheme.primary : null,
            ),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Log out'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_hasFilters)
            Material(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Filters active',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFiltersFromBar,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: expenseState.isLoading && expenseState.expenses.isEmpty
                ? const LoadingState()
                : expenseState.error != null
                    ? ErrorState(
                        message: expenseState.error!,
                        onRetry: () {
                          ref.read(expenseProvider.notifier).loadExpenses();
                        },
                      )
                    : expenseState.expenses.isEmpty
                        ? const EmptyState(
                            title: 'No expenses yet',
                            subtitle: 'Tap + to add your first expense.',
                          )
                        : RefreshIndicator(
                            edgeOffset: 8,
                            onRefresh: () async {
                              await ref
                                  .read(expenseProvider.notifier)
                                  .loadExpenses();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.pageHorizontal,
                                AppSpacing.md,
                                AppSpacing.pageHorizontal,
                                96,
                              ),
                              itemCount: expenseState.expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenseState.expenses[index];
                                return ExpenseCard(
                                  expense: expense,
                                  onEdit: () {
                                    context.push('/expenses/edit/${expense.id}',
                                        extra: {
                                          'description': expense.description,
                                          'amount': expense.amount,
                                          'category': expense.category,
                                          'expenseDate': expense.expenseDate,
                                        });
                                  },
                                  onDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        final t = Theme.of(context);
                                        return AlertDialog(
                                          title: Text(
                                            'Delete expense?',
                                            style: t.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          content: const Text(
                                            'This action cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    t.colorScheme.error,
                                                foregroundColor:
                                                    t.colorScheme.onError,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm == true) {
                                      await ref
                                          .read(expenseProvider.notifier)
                                          .removeExpense(expense.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          content:
                                              const Text('Expense deleted'),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/expenses/add');
        },
        tooltip: 'Add expense',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
