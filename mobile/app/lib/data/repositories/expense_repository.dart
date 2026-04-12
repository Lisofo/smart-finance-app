import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/services/dio_client.dart';
import '../datasources/expense_api.dart';
import '../models/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final expenseApi = ExpenseApi(ref.read(dioProvider));
  return ExpenseRepository(expenseApi);
});

class ExpenseRepository {
  final ExpenseApi expenseApi;

  ExpenseRepository(this.expenseApi);

  Future<List<ExpenseModel>> getExpenses({
    String? category,
    String? startDate,
    String? endDate,
  }) async {
    return await expenseApi.getExpenses(
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<ExpenseModel> createExpense({
    required String description,
    required double amount,
    String? category,
    required String expenseDate,
  }) async {
    return await expenseApi.createExpense(
      description: description,
      amount: amount,
      category: category,
      expenseDate: expenseDate,
    );
  }

  Future<ExpenseModel> updateExpense({
    required int id,
    String? description,
    double? amount,
    String? category,
    String? expenseDate,
  }) async {
    return await expenseApi.updateExpense(
      id: id,
      description: description,
      amount: amount,
      category: category,
      expenseDate: expenseDate,
    );
  }

  Future<void> deleteExpense(int id) async {
    await expenseApi.deleteExpense(id);
  }
}