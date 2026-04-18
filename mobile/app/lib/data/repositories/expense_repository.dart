import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/services/dio_client.dart';

import '../../core/errors/api_error_mapper.dart';
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
    try {
      return await expenseApi.getExpenses(
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
    } on DioException catch (e) {
      throw mapApiError(e);
    }
  }

  Future<ExpenseModel> createExpense({
    required String description,
    required double amount,
    String? category,
    required String expenseDate,
  }) async {
    try {
      return await expenseApi.createExpense(
        description: description,
        amount: amount,
        category: category,
        expenseDate: expenseDate,
      );
    } on DioException catch (e) {
      throw mapApiError(e);
    }
  }

  Future<ExpenseModel> updateExpense({
    required int id,
    String? description,
    double? amount,
    String? category,
    String? expenseDate,
  }) async {
    try {
      return await expenseApi.updateExpense(
        id: id,
        description: description,
        amount: amount,
        category: category,
        expenseDate: expenseDate,
      );
    } on DioException catch (e) {
      throw mapApiError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await expenseApi.deleteExpense(id);
    } on DioException catch (e) {
      throw mapApiError(e);
    }
  }
}
