import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/api/api_client.dart';
import '../../../data/api/interceptors/auth_interceptor.dart' as interceptor;
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

/// BLoC managing authentication state including login, logout,
/// token persistence, lockout after failed attempts, and 401 handling.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  /// Maximum consecutive failed login attempts before lockout.
  static const int maxFailedAttempts = 5;

  /// Duration of the lockout period after max failed attempts.
  static const Duration lockoutDuration = Duration(seconds: 60);

  StreamSubscription<interceptor.AuthEvent>? _authEventSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    ApiClient? apiClient,
  })  : _authRepository = authRepository,
        _apiClient = apiClient ?? ApiClient.instance,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    // Listen to 401 events from the API client's auth interceptor
    _authEventSubscription = _apiClient.authEventStream.listen((event) {
      if (event == interceptor.AuthEvent.unauthenticated) {
        add(const AuthSessionExpired());
      }
    });
  }

  /// Checks for an existing stored token on app start.
  /// If a token exists, transitions to authenticated state.
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _authRepository.getStoredToken();
    if (token != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        clearErrorMessage: true,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearErrorMessage: true,
      ));
    }
  }

  /// Handles login attempts with lockout logic.
  ///
  /// After 5 consecutive failed attempts, disables login for 60 seconds.
  /// On success, resets the failed attempt counter and emits authenticated.
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check if currently locked out
    if (state.isLockedOut) {
      final now = DateTime.now();
      if (state.lockoutEndTime != null && now.isBefore(state.lockoutEndTime!)) {
        final remaining = state.lockoutEndTime!.difference(now).inSeconds;
        emit(state.copyWith(
          errorMessage:
              'Too many failed attempts. Please wait $remaining seconds.',
        ));
        return;
      } else {
        // Lockout has expired, reset
        emit(state.copyWith(
          isLockedOut: false,
          failedAttempts: 0,
          clearLockoutEndTime: true,
          clearErrorMessage: true,
        ));
      }
    }

    try {
      await _authRepository.login(event.email, event.password);

      // Success: reset failed attempts and emit authenticated
      emit(const AuthState(
        status: AuthStatus.authenticated,
        failedAttempts: 0,
        isLockedOut: false,
      ));
    } catch (e) {
      final newFailedAttempts = state.failedAttempts + 1;

      if (newFailedAttempts >= maxFailedAttempts) {
        // Lock out the user for 60 seconds
        final lockoutEnd = DateTime.now().add(lockoutDuration);
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          failedAttempts: newFailedAttempts,
          isLockedOut: true,
          lockoutEndTime: lockoutEnd,
          errorMessage:
              'Too many failed attempts. Please wait 60 seconds.',
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          failedAttempts: newFailedAttempts,
          errorMessage: _extractErrorMessage(e),
        ));
      }
    }
  }

  /// Handles logout by clearing the token and emitting unauthenticated.
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Handles session expiration (401 from API).
  /// Clears the token and emits unauthenticated.
  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.clearToken();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Extracts a user-friendly error message from an exception.
  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      final message = error.toString();
      // DioException messages are already user-friendly thanks to ErrorInterceptor
      if (message.contains('Exception: ')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }
    return 'Login failed. Please check your credentials and try again.';
  }

  @override
  Future<void> close() {
    _authEventSubscription?.cancel();
    return super.close();
  }
}
