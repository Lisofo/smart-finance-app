import '../../data/repositories/auth_repository.dart';
import '../entities/user.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<(User, String)> call(String email, String password) async {
    final (userModel, token) = await repository.login(email, password);
    final user = User(
      id: userModel.id,
      email: userModel.email,
      createdAt: userModel.createdAt,
    );
    return (user, token);
  }
}