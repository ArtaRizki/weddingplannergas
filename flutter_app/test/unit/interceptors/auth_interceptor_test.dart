import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planner/data/api/interceptors/auth_interceptor.dart';

void main() {
  late _FakeSecureStorage fakeStorage;
  late StreamController<AuthEvent> authEventController;
  late AuthInterceptor interceptor;
  late Dio dio;

  setUp(() {
    fakeStorage = _FakeSecureStorage();
    authEventController = StreamController<AuthEvent>.broadcast();
    interceptor = AuthInterceptor(
      secureStorage: fakeStorage,
      authEventController: authEventController,
    );
    dio = Dio(BaseOptions(baseUrl: 'https://test.api.com'));
    dio.httpClientAdapter = _MockHttpAdapter();
    dio.interceptors.add(interceptor);
  });

  tearDown(() {
    interceptor.dispose();
    dio.close();
  });

  group('AuthInterceptor - Token injection', () {
    test('adds Authorization header when token is stored', () async {
      fakeStorage.setToken('test-token-123');

      // Add a capture interceptor after auth interceptor
      String? capturedAuthHeader;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedAuthHeader = options.headers['Authorization'] as String?;
          handler.next(options);
        },
      ));

      _MockHttpAdapter.nextStatusCode = 200;
      await dio.get('/api/dashboard');

      expect(capturedAuthHeader, equals('Bearer test-token-123'));
    });

    test('does not add Authorization header when no token is stored', () async {
      // No token set in storage
      String? capturedAuthHeader;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedAuthHeader = options.headers['Authorization'] as String?;
          handler.next(options);
        },
      ));

      _MockHttpAdapter.nextStatusCode = 200;
      await dio.get('/api/dashboard');

      expect(capturedAuthHeader, isNull);
    });

    test('does not add Authorization header when token is empty', () async {
      fakeStorage.setToken('');

      String? capturedAuthHeader;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedAuthHeader = options.headers['Authorization'] as String?;
          handler.next(options);
        },
      ));

      _MockHttpAdapter.nextStatusCode = 200;
      await dio.get('/api/dashboard');

      expect(capturedAuthHeader, isNull);
    });

    test('uses Bearer scheme in Authorization header', () async {
      fakeStorage.setToken('my-jwt-token');

      String? capturedAuthHeader;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedAuthHeader = options.headers['Authorization'] as String?;
          handler.next(options);
        },
      ));

      _MockHttpAdapter.nextStatusCode = 200;
      await dio.get('/api/tasks');

      expect(capturedAuthHeader, startsWith('Bearer '));
    });
  });

  group('AuthInterceptor - 401 handling', () {
    test('emits unauthenticated event on 401 response', () async {
      fakeStorage.setToken('expired-token');

      final events = <AuthEvent>[];
      final subscription = authEventController.stream.listen(events.add);

      _MockHttpAdapter.nextStatusCode = 401;

      try {
        await dio.get('/api/dashboard');
      } on DioException {
        // Expected
      }

      // Allow async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(events, contains(AuthEvent.unauthenticated));
      await subscription.cancel();
    });

    test('clears stored token on 401 response', () async {
      fakeStorage.setToken('expired-token');

      _MockHttpAdapter.nextStatusCode = 401;

      try {
        await dio.get('/api/dashboard');
      } on DioException {
        // Expected
      }

      // Allow async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(fakeStorage.readToken(), isNull);
    });

    test('does not emit unauthenticated event on non-401 errors', () async {
      final events = <AuthEvent>[];
      final subscription = authEventController.stream.listen(events.add);

      _MockHttpAdapter.nextStatusCode = 500;

      try {
        await dio.get('/api/dashboard');
      } on DioException {
        // Expected
      }

      await Future.delayed(const Duration(milliseconds: 100));

      expect(events, isEmpty);
      await subscription.cancel();
    });

    test('passes error to next handler after processing', () async {
      fakeStorage.setToken('expired-token');
      _MockHttpAdapter.nextStatusCode = 401;

      try {
        await dio.get('/api/dashboard');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.response?.statusCode, equals(401));
      }
    });
  });

  group('AuthInterceptor - authEventStream', () {
    test('stream is accessible', () {
      expect(interceptor.authEventStream, isA<Stream<AuthEvent>>());
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
    if (key == AuthInterceptor.tokenKey) {
      return _token;
    }
    return null;
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
    if (key == AuthInterceptor.tokenKey) {
      _token = null;
    }
  }
}

/// A mock HTTP adapter that returns configurable responses.
class _MockHttpAdapter implements HttpClientAdapter {
  static int nextStatusCode = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final statusCode = nextStatusCode;
    return ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
