import '../../data/repositories/auth_repository.dart';
import '../entities/user.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(String email, String password) async {
    final userModel = await repository.register(email, password);
    return User(
      id: userModel.id,
      email: userModel.email,
      createdAt: userModel.createdAt,
    );
  }
}