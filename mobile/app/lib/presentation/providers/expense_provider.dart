import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';

// Use case providers
final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  final repo = ref.read(expenseRepositoryProvider);
  return GetExpensesUseCase(repo);
});

final createExpenseUseCaseProvider = Provider<CreateExpenseUseCase>((ref) {
  final repo = ref.read(expenseRepositoryProvider);
  return CreateExpenseUseCase(repo);
});

final updateExpenseUseCaseProvider = Provider<UpdateExpenseUseCase>((ref) {
  final repo = ref.read(expenseRepositoryProvider);
  return UpdateExpenseUseCase(repo);
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  final repo = ref.read(expenseRepositoryProvider);
  return DeleteExpenseUseCase(repo);
});

// Expense filters
class ExpenseFilters {
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseFilters({this.category, this.startDate, this.endDate});

  ExpenseFilters copyWith({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExpenseFilters(
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// Expense state
class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;
  final ExpenseFilters filters;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
    this.filters = const ExpenseFilters(),
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
    ExpenseFilters? filters,
    bool clearError = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filters: filters ?? this.filters,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final GetExpensesUseCase _getExpensesUseCase;
  final CreateExpenseUseCase _createExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;

  ExpenseNotifier(
    this._getExpensesUseCase,
    this._createExpenseUseCase,
    this._updateExpenseUseCase,
    this._deleteExpenseUseCase,
  ) : super(ExpenseState());

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Clears cached expenses (e.g. after sign-out) so another session never sees stale rows.
  void reset() {
    state = const ExpenseState();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final expenses = await _getExpensesUseCase(
        category: state.filters.category,
        startDate: state.filters.startDate != null
            ? _formatDate(state.filters.startDate!)
            : null,
        endDate: state.filters.endDate != null
            ? _formatDate(state.filters.endDate!)
            : null,
      );
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _expenseErrorMessage(e));
    }
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    String? category,
    required DateTime expenseDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _createExpenseUseCase(
        description: description,
        amount: amount,
        category: category,
        expenseDate: _formatDate(expenseDate),
      );
      await loadExpenses(); // Reload list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _expenseErrorMessage(e));
    }
  }

  Future<void> editExpense({
    required int id,
    String? description,
    double? amount,
    String? category,
    DateTime? expenseDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _updateExpenseUseCase(
        id: id,
        description: description,
        amount: amount,
        category: category,
        expenseDate: expenseDate != null ? _formatDate(expenseDate) : null,
      );
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _expenseErrorMessage(e));
    }
  }

  Future<void> removeExpense(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _deleteExpenseUseCase(id);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _expenseErrorMessage(e));
    }
  }

  void updateFilters(ExpenseFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    loadExpenses();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

String _expenseErrorMessage(Object e) {
  if (e is String) return e;
  return e.toString();
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  final getUC = ref.read(getExpensesUseCaseProvider);
  final createUC = ref.read(createExpenseUseCaseProvider);
  final updateUC = ref.read(updateExpenseUseCaseProvider);
  final deleteUC = ref.read(deleteExpenseUseCaseProvider);
  return ExpenseNotifier(getUC, createUC, updateUC, deleteUC);
});