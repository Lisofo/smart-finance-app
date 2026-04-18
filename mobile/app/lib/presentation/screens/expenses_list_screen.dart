import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_dashboard_header.dart';
import '../widgets/feedback_states.dart';
import '../widgets/staggered_fade_in.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Filter expenses',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
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
    ref.read(expenseProvider.notifier).reset();
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subtitleParts = <String>[
      if (authState.user?.email != null) authState.user!.email,
      if (expenseState.expenses.isNotEmpty)
        '${expenseState.expenses.length} recorded'
      else
        'Your spending overview',
    ];

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: expenseState.isLoading && expenseState.expenses.isEmpty
          ? const SingleChildScrollView(
              key: ValueKey('loading'),
              child: ExpenseListSkeleton(),
            )
          : expenseState.error != null
              ? ErrorState(
                  key: const ValueKey('error'),
                  message: expenseState.error!,
                  onRetry: () {
                    ref.read(expenseProvider.notifier).loadExpenses();
                  },
                )
              : expenseState.expenses.isEmpty
                  ? const EmptyState(
                      key: ValueKey('empty'),
                      title: 'No expenses yet',
                      subtitle:
                          'Add your first expense with the + button — charts and insights appear here automatically.',
                    )
                  : RefreshIndicator(
                      key: const ValueKey('list'),
                      edgeOffset: 12,
                      onRefresh: () async {
                        await ref.read(expenseProvider.notifier).loadExpenses();
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageHorizontal,
                              AppSpacing.sm,
                              AppSpacing.pageHorizontal,
                              AppSpacing.md,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: ExpenseDashboardHeader(
                                expenses: expenseState.expenses,
                                hasActiveFilters: _hasFilters,
                              ),
                            ),
                          ),
                          if (_hasFilters)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.pageHorizontal,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Material(
                                    color: colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
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
                                              style: theme
                                                  .textTheme.labelLarge
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
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
                                ),
                              ),
                            ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageHorizontal,
                              0,
                              AppSpacing.pageHorizontal,
                              8,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.list_alt_rounded,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Transactions',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageHorizontal,
                              0,
                              AppSpacing.pageHorizontal,
                              96,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final expense = expenseState.expenses[index];
                                  return StaggeredFadeIn(
                                    key: ValueKey(expense.id),
                                    index: index,
                                    child: ExpenseCard(
                                      expense: expense,
                                      onEdit: () {
                                        context.push(
                                          '/expenses/edit/${expense.id}',
                                          extra: {
                                            'description': expense.description,
                                            'amount': expense.amount,
                                            'category': expense.category,
                                            'expenseDate': expense.expenseDate,
                                          },
                                        );
                                      },
                                      onDelete: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            final t = Theme.of(context);
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              title: Text(
                                                'Delete expense?',
                                                style: t.textTheme.titleLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              content: const Text(
                                                'This action cannot be undone.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  style:
                                                      FilledButton.styleFrom(
                                                    backgroundColor:
                                                        t.colorScheme.error,
                                                    foregroundColor: t
                                                        .colorScheme.onError,
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
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
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              content: const Text(
                                                'Expense deleted',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                                childCount: expenseState.expenses.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      title: Text(
                        'Overview',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.35,
                        ),
                      ),
                      subtitle: Text(
                        subtitleParts.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (expenseState.isLoading && expenseState.expenses.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
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
            ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        tooltip: 'Add expense',
        elevation: 3,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
