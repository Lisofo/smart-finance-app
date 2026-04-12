import '../../data/repositories/expense_repository.dart';
import '../entities/expense.dart';

class CreateExpenseUseCase {
  final ExpenseRepository repository;

  CreateExpenseUseCase(this.repository);

  Future<Expense> call({
    required String description,
    required double amount,
    String? category,
    required String expenseDate,
  }) async {
    final model = await repository.createExpense(
      description: description,
      amount: amount,
      category: category,
      expenseDate: expenseDate,
    );
    return Expense(
      id: model.id,
      description: model.description,
      amount: model.amount,
      category: model.category,
      expenseDate: DateTime.parse(model.expenseDate),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}