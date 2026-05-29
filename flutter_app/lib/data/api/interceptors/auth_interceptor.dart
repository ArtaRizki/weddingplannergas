import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor that injects the Bearer token from secure storage
/// into the Authorization header of every authenticated request.
///
/// Also listens for 401 responses to clear the stored token and
/// emit an unauthenticated status via [onAuthError].
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  /// Stream controller that emits when a 401 is received,
  /// signaling the app to redirect to the login screen.
  final StreamController<AuthEvent> _authEventController;

  /// Key used to store/retrieve the auth token in secure storage.
  static const String tokenKey = 'auth_token';

  /// Stream of auth events (e.g., token cleared due to 401).
  Stream<AuthEvent> get authEventStream => _authEventController.stream;

  AuthInterceptor({
    FlutterSecureStorage? secureStorage,
    StreamController<AuthEvent>? authEventController,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _authEventController =
            authEventController ?? StreamController<AuthEvent>.broadcast();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }
    handler.next(err);
  }

  /// Clears the stored token and emits an unauthenticated event.
  Future<void> _handleUnauthorized() async {
    await _secureStorage.delete(key: tokenKey);
    _authEventController.add(AuthEvent.unauthenticated);
  }

  /// Disposes the stream controller. Call when the interceptor is no longer needed.
  void dispose() {
    _authEventController.close();
  }
}

/// Events emitted by the [AuthInterceptor] to notify the app
/// about authentication state changes.
enum AuthEvent {
  /// Emitted when a 401 response is received, indicating the
  /// user's session is no longer valid.
  unauthenticated,
}
