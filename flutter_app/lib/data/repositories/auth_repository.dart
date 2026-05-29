import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../api/interceptors/auth_interceptor.dart';
import '../models/auth_token.dart';

/// Repository handling authentication operations including login, logout,
/// and token persistence via secure storage.
class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    ApiClient? apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient ?? ApiClient.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Authenticates the user with [email] and [password].
  ///
  /// Sends a POST request to `/api/login` and returns the [AuthToken]
  /// on success. Throws on network or server errors.
  Future<AuthToken> login(String email, String password) async {
    final response = await _apiClient.post(
      '/api/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final token = AuthToken.fromJson(data);

    // Persist the token in secure storage
    await _secureStorage.write(
      key: AuthInterceptor.tokenKey,
      value: token.accessToken,
    );

    return token;
  }

  /// Logs out the user by calling the API and clearing the stored token.
  ///
  /// Sends a POST request to `/api/logout` (authenticated).
  /// Always clears the local token regardless of API response.
  Future<void> logout() async {
    try {
      await _apiClient.post('/api/logout');
    } finally {
      await clearToken();
    }
  }

  /// Retrieves the stored authentication token, if any.
  ///
  /// Returns an [AuthToken] if a token exists in secure storage,
  /// or `null` if no token is stored.
  Future<AuthToken?> getStoredToken() async {
    final token = await _secureStorage.read(key: AuthInterceptor.tokenKey);
    if (token != null && token.isNotEmpty) {
      return AuthToken(accessToken: token);
    }
    return null;
  }

  /// Clears the stored authentication token from secure storage.
  Future<void> clearToken() async {
    await _secureStorage.delete(key: AuthInterceptor.tokenKey);
  }
}
