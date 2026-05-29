import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Interceptor that maps HTTP error status codes to user-friendly
/// error messages and logs technical details to the debug console.
///
/// - 4xx/5xx responses are mapped to safe, non-technical messages.
/// - Technical details (status code, endpoint, response body) are
///   logged via `developer.log` for debugging purposes only.
/// - Timeout exceptions are caught and mapped to a connection timeout message.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);

    final userMessage = _mapToUserFriendlyMessage(err);

    final mappedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: userMessage,
      message: userMessage,
    );

    handler.next(mappedError);
  }

  /// Maps a [DioException] to a user-friendly error message string.
  /// Does not expose technical details such as status codes or stack traces.
  String _mapToUserFriendlyMessage(DioException err) {
    // Handle timeout errors
    if (_isTimeoutError(err)) {
      return 'Connection timeout. Please check your internet connection and try again.';
    }

    // Handle connection errors (no internet, DNS failure, etc.)
    if (err.type == DioExceptionType.connectionError) {
      return 'Unable to connect. Please check your internet connection.';
    }

    // Handle cancel
    if (err.type == DioExceptionType.cancel) {
      return 'Request was cancelled.';
    }

    // Handle HTTP status code errors
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      return _mapStatusCodeToMessage(statusCode);
    }

    // Fallback for unknown errors
    return 'An unexpected error occurred. Please try again.';
  }

  /// Maps an HTTP status code to a user-friendly message.
  String _mapStatusCodeToMessage(int statusCode) {
    if (statusCode == 400) {
      return 'Invalid request. Please check your input and try again.';
    }
    if (statusCode == 401) {
      return 'Your session has expired. Please log in again.';
    }
    if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }
    if (statusCode == 404) {
      return 'The requested resource was not found.';
    }
    if (statusCode == 422) {
      return 'Invalid input. Please review your data and try again.';
    }
    if (statusCode == 429) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    if (statusCode >= 400 && statusCode < 500) {
      return 'Something went wrong with your request. Please try again.';
    }
    if (statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Returns true if the error is a timeout (connect, receive, or send).
  bool _isTimeoutError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }

  /// Logs the HTTP status code, endpoint, and response body to the
  /// debug console for developer troubleshooting. Does NOT expose
  /// these details to the user.
  void _logError(DioException err) {
    final statusCode = err.response?.statusCode;
    final endpoint =
        '${err.requestOptions.method} ${err.requestOptions.uri}';
    final responseBody = err.response?.data;

    developer.log(
      'API Error: [$statusCode] $endpoint',
      name: 'ErrorInterceptor',
      error: responseBody?.toString(),
    );
  }
}
