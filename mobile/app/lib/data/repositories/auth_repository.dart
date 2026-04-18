import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/services/dio_client.dart';

import '../../core/errors/api_error_mapper.dart';
import '../../core/services/secure_storage_service.dart';
import '../datasources/auth_api.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = AuthApi(ref.read(dioProvider));
  return AuthRepository(authApi);
});

class AuthRepository {
  final AuthApi authApi;
  final SecureStorageService _storage = SecureStorageService();

  AuthRepository(this.authApi);

  Future<UserModel> register(String email, String password) async {
    try {
      final response = await authApi.register(email, password);
      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
      return user;
    } on DioException catch (e) {
      throw mapApiError(e);
    }
  }

  Future<(UserModel, String)> login(String email, String password) async {
    try {
      final response = await authApi.login(email, password);
      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
      final token = response['token'] as String;

      await _storage.saveToken(token);
      await _storage.saveUser(jsonEncode(user.toJson()));

      return (user, token);
    } on DioException catch (e) {
      throw mapApiError(e);
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  Future<UserModel?> getStoredUser() async {
    final userJson = await _storage.getUser();
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userMap =
          jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }
}
