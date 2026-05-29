import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planner/data/api/api_client.dart';
import 'package:wedding_planner/data/api/interceptors/auth_interceptor.dart'
    as interceptor;
import 'package:wedding_planner/data/repositories/auth_repository.dart';
import 'package:wedding_planner/domain/blocs/auth/auth_bloc.dart';

void main() {
  late _FakeSecureStorage fakeStorage;
  late ApiClient apiClient;
  late AuthRepository authRepository;
  late _MockHttpAdapter mockAdapter;

  setUp(() {
    fakeStorage = _FakeSecureStorage();
    apiClient = ApiClient(
      baseUrl: 'https://test.api.com',
      secureStorage: fakeStorage,
    );
    mockAdapter = _MockHttpAdapter();
    apiClient.dio.httpClientAdapter = mockAdapter;
    authRepository = AuthRepository(
      apiClient: apiClient,
      secureStorage: fakeStorage,
    );
  });

  group('AuthBloc - Initial state', () {
    blocTest<AuthBloc, AuthState>(
      'initial state is AuthStatus.unknown',
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      verify: (bloc) {
        expect(bloc.state.status, equals(AuthStatus.unknown));
        expect(bloc.state.failedAttempts, equals(0));
        expect(bloc.state.isLockedOut, isFalse);
      },
    );
  });

  group('AuthBloc - AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when token exists in storage',
      setUp: () {
        fakeStorage.setToken('existing-token');
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when no token in storage',
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );
  });

  group('AuthBloc - AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated on successful login',
      setUp: () {
        mockAdapter.nextResponse = const _MockResponse(
          statusCode: 200,
          body:
              '{"success":true,"data":{"access_token":"new-token","token_type":"Bearer"},"message":"Login successful"}',
        );
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated),
      ],
      verify: (_) {
        expect(fakeStorage.readToken(), equals('new-token'));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated with error on failed login',
      setUp: () {
        mockAdapter.nextResponse = const _MockResponse(
          statusCode: 422,
          body: '{"success":false,"message":"Invalid credentials"}',
        );
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'wrong',
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.failedAttempts, 'failedAttempts', 1)
            .having((s) => s.isLockedOut, 'isLockedOut', false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'increments failed attempts on each failed login',
      setUp: () {
        mockAdapter.nextResponse = const _MockResponse(
          statusCode: 422,
          body: '{"success":false,"message":"Invalid credentials"}',
        );
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      seed: () => const AuthState(
        status: AuthStatus.unauthenticated,
        failedAttempts: 3,
      ),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'wrong',
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.failedAttempts, 'failedAttempts', 4)
            .having((s) => s.isLockedOut, 'isLockedOut', false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'locks out after 5 consecutive failed attempts',
      setUp: () {
        mockAdapter.nextResponse = const _MockResponse(
          statusCode: 422,
          body: '{"success":false,"message":"Invalid credentials"}',
        );
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      seed: () => const AuthState(
        status: AuthStatus.unauthenticated,
        failedAttempts: 4,
      ),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'wrong',
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.failedAttempts, 'failedAttempts', 5)
            .having((s) => s.isLockedOut, 'isLockedOut', true)
            .having((s) => s.lockoutEndTime, 'lockoutEndTime', isNotNull)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Too many failed attempts')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'rejects login attempt during lockout period',
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      seed: () => AuthState(
        status: AuthStatus.unauthenticated,
        failedAttempts: 5,
        isLockedOut: true,
        lockoutEndTime: DateTime.now().add(const Duration(seconds: 30)),
        errorMessage: 'Too many failed attempts. Please wait 60 seconds.',
      ),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.isLockedOut, 'isLockedOut', true)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Too many failed attempts')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'allows login after lockout period expires',
      setUp: () {
        mockAdapter.nextResponse = const _MockResponse(
          statusCode: 200,
          body:
              '{"success":true,"data":{"access_token":"new-token","token_type":"Bearer"},"message":"Login successful"}',
        );
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      seed: () => AuthState(
        status: AuthStatus.unauthenticated,
        failedAttempts: 5,
        isLockedOut: true,
        lockoutEndTime: DateTime.now().subtract(const Duration(seconds: 1)),
        errorMessage: 'Too many failed attempts. Please wait 60 seconds.',
      ),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        // First: lockout reset
        isA<AuthState>()
            .having((s) => s.isLockedOut, 'isLockedOut', false)
            .having((s) => s.failedAttempts, 'failedAttempts', 0),
        // Then: successful login
        const AuthState(status: AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'resets failed attempts on successful login',
      setUp: () {
        mockAdapter.nextResponse = const _MockResponse(
          statusCode: 200,
          body:
              '{"success":true,"data":{"access_token":"new-token","token_type":"Bearer"},"message":"Login successful"}',
        );
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      seed: () => const AuthState(
        status: AuthStatus.unauthenticated,
        failedAttempts: 3,
      ),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated),
      ],
    );
  });

  group('AuthBloc - AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated and clears token on logout',
      setUp: () {
        fakeStorage.setToken('existing-token');
        mockAdapter.nextResponse = const _MockResponse(
          statusCode: 200,
          body: '{"success":true,"message":"Logged out"}',
        );
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      seed: () => const AuthState(status: AuthStatus.authenticated),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
      verify: (_) {
        expect(fakeStorage.readToken(), isNull);
      },
    );
  });

  group('AuthBloc - AuthSessionExpired (401 handling)', () {
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated and clears token on session expiry',
      setUp: () {
        fakeStorage.setToken('expired-token');
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      seed: () => const AuthState(status: AuthStatus.authenticated),
      act: (bloc) => bloc.add(const AuthSessionExpired()),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
      verify: (_) {
        expect(fakeStorage.readToken(), isNull);
      },
    );
  });

  group('AuthBloc - 401 stream listener', () {
    test('listens to authEventStream and emits unauthenticated on 401',
        () async {
      fakeStorage.setToken('some-token');
      mockAdapter.nextResponse = const _MockResponse(
        statusCode: 401,
        body: '{"success":false,"message":"Unauthenticated"}',
      );

      final bloc = AuthBloc(
        authRepository: authRepository,
        apiClient: apiClient,
      );

      // Trigger a 401 response through the API client
      try {
        await apiClient.get('/api/dashboard');
      } on DioException {
        // Expected
      }

      // Allow async operations to complete
      await Future.delayed(const Duration(milliseconds: 300));

      expect(bloc.state.status, equals(AuthStatus.unauthenticated));
      expect(fakeStorage.readToken(), isNull);

      await bloc.close();
    });
  });
}


/// A fake implementation of FlutterSecureStorage for testing.
class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  String? readToken() => _token;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == interceptor.AuthInterceptor.tokenKey) {
      return _token;
    }
    return null;
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == interceptor.AuthInterceptor.tokenKey) {
      _token = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == interceptor.AuthInterceptor.tokenKey) {
      _token = null;
    }
  }
}

/// Mock response configuration.
class _MockResponse {
  final int statusCode;
  final String body;

  const _MockResponse({required this.statusCode, required this.body});
}

/// A mock HTTP adapter that returns configurable responses.
class _MockHttpAdapter implements HttpClientAdapter {
  _MockResponse nextResponse = const _MockResponse(
    statusCode: 200,
    body: '{}',
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = nextResponse;
    return ResponseBody.fromString(
      response.body,
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
