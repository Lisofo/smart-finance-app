import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, createdAt];
}