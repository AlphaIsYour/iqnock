import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    if (token == null) return false;

    // Verify token dengan API
    try {
      final response = await _apiService.getProfile();
      return response['success'] == true;
    } catch (e) {
      // Token invalid/expired
      await logout();
      return false;
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.login(email: email, password: password);

    // Token udah auto-saved di ApiService
    return response;
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    // Token udah auto-saved di ApiService
    return response;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore error, tetap clear token
    }
    await _apiService.clearToken();
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.getProfile();
      if (response['success'] == true) {
        return response['data'];
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
}
