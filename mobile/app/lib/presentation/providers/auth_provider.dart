import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/secure_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// Providers for use cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return LoginUseCase(authRepo);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return RegisterUseCase(authRepo);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return LogoutUseCase(authRepo);
});

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final SecureStorageService _storage = SecureStorageService();

  AuthNotifier(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
  ) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final (user, _) = await _loginUseCase(email, password);
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _registerUseCase(email, password);
      // After registration, we don't auto-login; user must login
      state = state.copyWith(
        user: user,
        isLoading: false,
        // isAuthenticated remains false until they login
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    state = AuthState(); // Reset state
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getToken();
    if (token != null) {
      // Optionally fetch user data again
      // For simplicity, we'll just mark as authenticated without user object
      // You can extend to load user from storage
      state = state.copyWith(isAuthenticated: true);
    } else {
      state = state.copyWith(isAuthenticated: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUC = ref.read(loginUseCaseProvider);
  final registerUC = ref.read(registerUseCaseProvider);
  final logoutUC = ref.read(logoutUseCaseProvider);
  return AuthNotifier(loginUC, registerUC, logoutUC);
});