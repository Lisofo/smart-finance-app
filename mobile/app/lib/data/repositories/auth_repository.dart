import 'dart:convert'; // REQUIRED for jsonEncode/jsonDecode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/services/dio_client.dart';
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
    final response = await authApi.register(email, password);
    final user = UserModel.fromJson(response['user']);
    return user;
  }

  Future<(UserModel, String)> login(String email, String password) async {
    final response = await authApi.login(email, password);
    final user = UserModel.fromJson(response['user']);
    final token = response['token'] as String;
    
    await _storage.saveToken(token);
    // FIX: Use jsonEncode instead of .toString()
    await _storage.saveUser(jsonEncode(user.toJson())); 
    
    return (user, token);
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
      // FIX: Decode the string back into a Map
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }
}