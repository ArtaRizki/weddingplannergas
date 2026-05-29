import 'package:equatable/equatable.dart';

/// Events for the [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on app start to check for an existing stored token.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Triggered when the user submits login credentials.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Triggered when the user taps the logout button.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Triggered when a 401 response is received from the API,
/// indicating the session is no longer valid.
class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
