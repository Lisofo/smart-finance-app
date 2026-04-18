import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/expense.dart';
import 'charts/expense_category_chart.dart';

/// Summary card (month total + count) and category visualization.
class ExpenseDashboardHeader extends StatelessWidget {
  final List<Expense> expenses;
  final bool hasActiveFilters;

  const ExpenseDashboardHeader({
    super.key,
    required this.expenses,
    this.hasActiveFilters = false,
  });

  static double _monthTotal(List<Expense> items, DateTime now) {
    return items
        .where(
          (e) =>
              e.expenseDate.year == now.year &&
              e.expenseDate.month == now.month,
        )
        .fold<double>(0, (a, e) => a + e.amount);
  }

  static double _visibleTotal(List<Expense> items) {
    return items.fold<double>(0, (a, e) => a + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final monthFmt = DateFormat.yMMMM();
    final currency = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    final monthTotal = _monthTotal(expenses, now);
    final listTotal = _visibleTotal(expenses);
    final monthCount = expenses
        .where(
          (e) =>
              e.expenseDate.year == now.year &&
              e.expenseDate.month == now.month,
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.88),
                const Color(0xFF1D4ED8),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        monthFmt.format(now),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (hasActiveFilters)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Filtered',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Spent this month',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currency.format(monthTotal),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  monthCount == 0
                      ? 'No entries this month yet'
                      : '$monthCount ${monthCount == 1 ? 'expense' : 'expenses'} this month · ${currency.format(listTotal)} in view',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expenses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: colorScheme.surface,
            elevation: 0.5,
            shadowColor: AppColors.shadow,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pie_chart_outline_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'By category',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasActiveFilters
                        ? 'Share of amounts in your current filter'
                        : 'Share of your listed expenses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RepaintBoundary(
                    child: ExpenseCategoryChart(expenses: expenses),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
