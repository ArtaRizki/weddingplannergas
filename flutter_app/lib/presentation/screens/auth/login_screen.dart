import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/form_validators.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../domain/blocs/auth/auth_bloc.dart';

/// Login screen with neobrutalist styling.
///
/// Features:
/// - Email and password input with validation
/// - Generic error message for invalid credentials (does not reveal which field is wrong)
/// - Retains email on network failure
/// - Disables login button for 60s after 5 failed attempts with countdown
/// - Loading state on button while login is in progress
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  // Lockout countdown
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime lockoutEndTime) {
    _countdownTimer?.cancel();
    final now = DateTime.now();
    final remaining = lockoutEndTime.difference(now).inSeconds;
    if (remaining <= 0) return;

    setState(() {
      _remainingSeconds = remaining;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  bool _validateForm() {
    final emailError = FormValidators.email(_emailController.text);
    final passwordError = FormValidators.minLength(
      _passwordController.text,
      8,
      fieldName: 'Password',
    );
    // Also check password is not empty
    final passwordRequired = FormValidators.required(
      _passwordController.text,
      fieldName: 'Password',
    );

    setState(() {
      _emailError = emailError;
      _passwordError = passwordRequired ?? passwordError;
      _generalError = null;
    });

    return emailError == null && passwordRequired == null && passwordError == null;
  }

  void _onLoginPressed() {
    if (!_validateForm()) return;

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // Handle lockout
            if (state.isLockedOut && state.lockoutEndTime != null) {
              _startCountdown(state.lockoutEndTime!);
            }

            // Handle error messages
            if (state.errorMessage != null) {
              setState(() {
                _generalError = state.errorMessage;
                // Clear field-specific errors when showing general error
                _emailError = null;
                _passwordError = null;
              });
            }

            // Handle successful authentication - navigation is handled by the router
          },
          builder: (context, state) {
            final isLockedOut = state.isLockedOut && _remainingSeconds > 0;
            final isSubmitting = state.status == AuthStatus.unknown;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App title
                      Text(
                        'Wedding Planner',
                        style: AppTypography.h1.copyWith(
                          color: AppTheme.pink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk ke akun Anda',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppTheme.darkGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Login form card
                      NeoCard(
                        backgroundColor: AppTheme.white,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // General error message
                            if (_generalError != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.pink.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.pink,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppTheme.pink,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _generalError!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppTheme.pink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email field
                            NeoTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'contoh@email.com',
                              keyboardType: TextInputType.emailAddress,
                              maxLength: 255,
                              errorText: _emailError,
                              enabled: !isSubmitting,
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppTheme.darkGray,
                                size: 20,
                              ),
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            NeoTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: 'Minimal 8 karakter',
                              obscureText: _obscurePassword,
                              errorText: _passwordError,
                              enabled: !isSubmitting,
                              prefixIcon: const Icon(
                                Icons.lock_outlined,
                                color: AppTheme.darkGray,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.darkGray,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              onChanged: (_) {
                                if (_passwordError != null) {
                                  setState(() => _passwordError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            // Lockout message
                            if (isLockedOut) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightPink,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.black,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      color: AppTheme.black,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Terlalu banyak percobaan gagal',
                                      style: AppTypography.caption.copyWith(
                                        color: AppTheme.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Coba lagi dalam $_remainingSeconds detik',
                                      style: AppTypography.body.copyWith(
                                        color: AppTheme.darkGray,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Login button
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: NeoButton(
                                  onPressed: isLockedOut ? null : _onLoginPressed,
                                  label: 'Masuk',
                                  icon: Icons.login,
                                  isLoading: isSubmitting,
                                  isDisabled: isLockedOut,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
