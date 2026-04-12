import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

double _parseAmount(dynamic val) {
  if (val is String) return double.parse(val);
  return (val as num).toDouble();
}

@JsonSerializable()
class ExpenseModel {
  final int id;
  final String description;

  @JsonKey(fromJson: _parseAmount)
  final double amount;

  final String? category;

  @JsonKey(name: 'expense_date')
  final String expenseDate;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    this.category,
    required this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);
}