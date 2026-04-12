import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Import auth first
import '../providers/auth_provider.dart';
// Hide authProvider from expense_provider to resolve the 'ambiguous_import' error
import '../providers/expense_provider.dart'; 
import '../widgets/expense_card.dart';
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

  @override
  void initState() {
    super.initState();
    // Schedule the load after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseProvider.notifier).loadExpenses();
    });
  }

  void _applyFilters() {
    ref.read(expenseProvider.notifier).updateFilters(
      ExpenseFilters( // Ensure this class is defined in expense_provider.dart
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  initialValue: _selectedCategory,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...AppConstants.expenseCategories.map((cat) =>
                      DropdownMenuItem(value: cat, child: Text(cat))),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(_startDate == null
                      ? 'Start Date'
                      : 'Start: ${DateFormat.yMMMd().format(_startDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
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
                ListTile(
                  title: Text(_endDate == null
                      ? 'End Date'
                      : 'End: ${DateFormat.yMMMd().format(_endDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
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
            );
          },
        ),
        actions: [
          TextButton(onPressed: _clearFilters, child: const Text('Clear')),
          TextButton(onPressed: _applyFilters, child: const Text('Apply')),
        ],
      ),
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
    // Removed unused authState variable to clear the warning

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
          ),
        ],
      ),
      body: expenseState.isLoading && expenseState.expenses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : expenseState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${expenseState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(expenseProvider.notifier).loadExpenses();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : expenseState.expenses.isEmpty
                  ? const Center(
                      child: Text('No expenses found. Add one!'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(expenseProvider.notifier).loadExpenses();
                      },
                      child: ListView.builder(
                        itemCount: expenseState.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenseState.expenses[index];
                          return ExpenseCard(
                            expense: expense,
                            onEdit: () {
                              context.push('/expenses/edit/${expense.id}', extra: {
                                'description': expense.description,
                                'amount': expense.amount,
                                'category': expense.category,
                                'expenseDate': expense.expenseDate,
                              });
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Expense'),
                                  content: const Text('Are you sure you want to delete this expense?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(expenseProvider.notifier).removeExpense(expense.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Expense deleted')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/expenses/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}