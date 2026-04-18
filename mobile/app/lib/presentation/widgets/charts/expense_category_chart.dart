import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/category_styles.dart';
import '../../../domain/entities/expense.dart';

class _Slice {
  const _Slice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

/// Donut chart: share of spending by category for the given expenses.
class ExpenseCategoryChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseCategoryChart({
    super.key,
    required this.expenses,
  });

  static List<_Slice> _slicesFrom(List<Expense> items) {
    final map = <String, double>{};
    for (final e in items) {
      final key = e.category ?? 'uncategorized';
      map[key] = (map[key] ?? 0) + e.amount;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .map(
          (e) => _Slice(
            label: _formatLabel(e.key),
            value: e.value,
            color: CategoryStyles.colorFor(e.key == 'uncategorized' ? null : e.key),
          ),
        )
        .toList();
  }

  static String _formatLabel(String key) {
    if (key == 'uncategorized') return 'Uncategorized';
    return key[0].toUpperCase() + key.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: r'$', decimalDigits: 0);
    final slices = _slicesFrom(expenses);
    final total = slices.fold<double>(0, (a, s) => a + s.value);
    if (total <= 0 || slices.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final chartSize = size.clamp(220.0, 340.0);
        final centerRadius = chartSize * 0.22;
        final sectionRadius = chartSize * 0.26;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: chartSize,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: centerRadius,
                  startDegreeOffset: -90,
                  sections: [
                    for (final s in slices)
                      PieChartSectionData(
                        color: s.color,
                        value: s.value,
                        radius: sectionRadius,
                        showTitle: s.value / total >= 0.08,
                        title: '${(s.value / total * 100).round()}%',
                        titleStyle: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final s in slices)
                  _LegendDot(
                    color: s.color,
                    label: s.label,
                    value: currency.format(s.value),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
