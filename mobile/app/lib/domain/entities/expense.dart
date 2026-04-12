import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int id;
  final String description;
  final double amount;
  final String? category;
  final DateTime expenseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    this.category,
    required this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, description, amount, category, expenseDate];
}