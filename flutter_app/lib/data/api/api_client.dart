import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Central HTTP client wrapping Dio with configurable base URL
/// and 30-second timeout for all request operations.
///
/// Usage:
/// ```dart
/// final client = ApiClient(); // uses Env.apiBaseUrl
/// final client = ApiClient(baseUrl: 'https://custom.api.com');
/// ```
///
/// Interceptors can be added via the [dio] getter:
/// ```dart
/// client.dio.interceptors.add(AuthInterceptor(tokenStorage));
/// client.dio.interceptors.add(ErrorInterceptor());
/// ```
class ApiClient {
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  /// Singleton instance for app-wide usage.
  static ApiClient? _instance;

  /// Returns the singleton instance of [ApiClient].
  /// Creates one with default configuration if not yet initialized.
  static ApiClient get instance {
    _instance ??= ApiClient();
    return _instance!;
  }

  /// Initializes the singleton with custom configuration.
  /// Should be called once during app startup if custom config is needed.
  static void initialize({String? baseUrl, FlutterSecureStorage? secureStorage}) {
    _instance = ApiClient(baseUrl: baseUrl, secureStorage: secureStorage);
  }

  /// Creates an [ApiClient] with the given [baseUrl].
  /// If [baseUrl] is not provided, uses [Env.apiBaseUrl].
  ///
  /// All timeouts (connect, receive, send) are set to 30 seconds
  /// as per requirement 1.6.
  ///
  /// Interceptors are added in order:
  /// 1. [AuthInterceptor] — injects Bearer token into requests
  /// 2. [ErrorInterceptor] — maps errors to user-friendly messages
  ApiClient({String? baseUrl, FlutterSecureStorage? secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _authInterceptor = AuthInterceptor(
      secureStorage: secureStorage ?? const FlutterSecureStorage(),
    );

    _dio.interceptors.addAll([
      _authInterceptor,
      ErrorInterceptor(),
    ]);
  }

  /// Stream of auth events from the [AuthInterceptor].
  /// Listen to this stream to handle 401 responses (e.g., redirect to login).
  Stream<AuthEvent> get authEventStream => _authInterceptor.authEventStream;

  /// Exposes the underlying Dio instance for adding interceptors.
  Dio get dio => _dio;

  /// The configured base URL.
  String get baseUrl => _dio.options.baseUrl;

  /// Performs a GET request to [path] with optional [queryParams].
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) {
    return _dio.get(path, queryParameters: queryParams);
  }

  /// Performs a POST request to [path] with optional [data] body.
  Future<Response> post(
    String path, {
    dynamic data,
  }) {
    return _dio.post(path, data: data);
  }

  /// Performs a PUT request to [path] with optional [data] body.
  Future<Response> put(
    String path, {
    dynamic data,
  }) {
    return _dio.put(path, data: data);
  }

  /// Performs a PATCH request to [path] with optional [data] body.
  Future<Response> patch(
    String path, {
    dynamic data,
  }) {
    return _dio.patch(path, data: data);
  }

  /// Performs a DELETE request to [path].
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
