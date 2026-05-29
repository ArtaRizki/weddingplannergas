import 'package:equatable/equatable.dart';

/// Possible authentication statuses.
enum AuthStatus {
  /// Initial state before the app has checked for a stored token.
  unknown,

  /// User is authenticated with a valid token.
  authenticated,

  /// User is not authenticated (no token or token cleared).
  unauthenticated,
}

/// State for the [AuthBloc].
class AuthState extends Equatable {
  /// The current authentication status.
  final AuthStatus status;

  /// Number of consecutive failed login attempts.
  final int failedAttempts;

  /// Whether the login is currently locked out due to too many failed attempts.
  final bool isLockedOut;

  /// The time when the lockout expires (null if not locked out).
  final DateTime? lockoutEndTime;

  /// Error message from the last failed login attempt.
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.failedAttempts = 0,
    this.isLockedOut = false,
    this.lockoutEndTime,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced.
  AuthState copyWith({
    AuthStatus? status,
    int? failedAttempts,
    bool? isLockedOut,
    DateTime? lockoutEndTime,
    String? errorMessage,
    bool clearLockoutEndTime = false,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      isLockedOut: isLockedOut ?? this.isLockedOut,
      lockoutEndTime:
          clearLockoutEndTime ? null : (lockoutEndTime ?? this.lockoutEndTime),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        failedAttempts,
        isLockedOut,
        lockoutEndTime,
        errorMessage,
      ];
}
