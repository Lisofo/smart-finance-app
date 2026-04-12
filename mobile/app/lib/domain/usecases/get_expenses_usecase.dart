import '../../data/repositories/expense_repository.dart';
import '../entities/expense.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  Future<List<Expense>> call({
    String? category,
    String? startDate,
    String? endDate,
  }) async {
    final models = await repository.getExpenses(
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
    return models.map((model) => Expense(
      id: model.id,
      description: model.description,
      amount: model.amount,
      category: model.category,
      expenseDate: DateTime.parse(model.expenseDate),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }
}