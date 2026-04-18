import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/secure_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

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
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;
  final SecureStorageService _storage = SecureStorageService();

  AuthNotifier(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._authRepository,
  ) : super(AuthState());

  /// Restores JWT + user from secure storage (call from [main] before [runApp]).
  Future<void> restoreSession() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      state = AuthState();
      return;
    }
    final userModel = await _authRepository.getStoredUser();
    state = AuthState(
      user: userModel != null
          ? User(
              id: userModel.id,
              email: userModel.email,
              createdAt: userModel.createdAt,
            )
          : null,
      isAuthenticated: true,
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, clearError: true);
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
        error: _authErrorMessage(e),
        isAuthenticated: false,
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, clearError: true);
    try {
      final user = await _registerUseCase(email, password);
      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _authErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    state = AuthState();
  }
}

String _authErrorMessage(Object e) {
  if (e is String) return e;
  return e.toString();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUC = ref.read(loginUseCaseProvider);
  final registerUC = ref.read(registerUseCaseProvider);
  final logoutUC = ref.read(logoutUseCaseProvider);
  final authRepo = ref.read(authRepositoryProvider);
  return AuthNotifier(loginUC, registerUC, logoutUC, authRepo);
});
