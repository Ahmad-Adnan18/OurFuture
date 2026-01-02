import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Authentication Service for login, register, logout
class AuthService {
  final ApiService _api = ApiService();
  
  // Expose api service for other operations
  ApiService get apiService => _api;

  // ... (login, register, logout methods remain same)

  /// Update user profile
  Future<User> updateProfile(String name, String email, {File? photo}) async {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
    };

    if (photo != null) {
      data['photo'] = await MultipartFile.fromFile(photo.path);
    }

    // Use FormData for file upload
    final formData = FormData.fromMap(data);

    // Use POST for file upload compatibility
    final response = await _api.post(
      ApiConfig.authUser,
      data: formData, 
    );
    return User.fromJson(response.data['user']);
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final response = await _api.post(
      ApiConfig.authLogin,
      data: {
        'email': email,
        'password': password,
        'device_name': deviceName ?? 'flutter_app',
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);
    
    // Store token
    await _api.setToken(authResponse.token);
    
    return authResponse;
  }

  /// Register new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post(
      ApiConfig.authRegister,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);
    
    // Store token
    await _api.setToken(authResponse.token);
    
    return authResponse;
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.authLogout);
    } finally {
      // Always clear token, even if API call fails
      await _api.clearToken();
    }
  }



  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    final response = await _api.get(ApiConfig.authUser);
    return User.fromJson(response.data['user']);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _api.hasToken();
  }
}
