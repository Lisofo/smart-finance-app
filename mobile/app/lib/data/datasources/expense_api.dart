import 'package:dio/dio.dart';
import '../models/expense_model.dart';

class ExpenseApi {
  final Dio dio;

  ExpenseApi(this.dio);

  Future<List<ExpenseModel>> getExpenses({
    String? category,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await dio.get('/api/expenses', queryParameters: queryParams);
    final List<dynamic> data = response.data['expenses'];
    return data.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  Future<ExpenseModel> createExpense({
    required String description,
    required double amount,
    String? category,
    required String expenseDate,
  }) async {
    final response = await dio.post('/api/expenses', data: {
      'description': description,
      'amount': amount,
      'category': category,
      'expenseDate': expenseDate,
    });
    return ExpenseModel.fromJson(response.data['expense']);
  }

  Future<ExpenseModel> updateExpense({
    required int id,
    String? description,
    double? amount,
    String? category,
    String? expenseDate,
  }) async {
    final data = <String, dynamic>{};
    if (description != null) data['description'] = description;
    if (amount != null) data['amount'] = amount;
    if (category != null) data['category'] = category;
    if (expenseDate != null) data['expenseDate'] = expenseDate;

    final response = await dio.put('/api/expenses/$id', data: data);
    return ExpenseModel.fromJson(response.data['expense']);
  }

  Future<void> deleteExpense(int id) async {
    await dio.delete('/api/expenses/$id');
  }
}