import '../../data/repositories/expense_repository.dart';
import '../entities/expense.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<Expense> call({
    required int id,
    String? description,
    double? amount,
    String? category,
    String? expenseDate,
  }) async {
    final model = await repository.updateExpense(
      id: id,
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