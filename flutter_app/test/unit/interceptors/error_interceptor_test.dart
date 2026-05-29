import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planner/data/api/interceptors/error_interceptor.dart';

void main() {
  late ErrorInterceptor interceptor;
  late Dio dio;

  setUp(() {
    interceptor = ErrorInterceptor();
    dio = Dio(BaseOptions(baseUrl: 'https://test.api.com'));
    dio.httpClientAdapter = _MockHttpAdapter();
    dio.interceptors.add(interceptor);
  });

  tearDown(() {
    dio.close();
  });

  group('ErrorInterceptor - HTTP status code mapping', () {
    test('maps 400 to user-friendly invalid request message', () async {
      _MockHttpAdapter.nextStatusCode = 400;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Invalid request'));
        expect(e.message, isNot(contains('400')));
      }
    });

    test('maps 401 to session expired message', () async {
      _MockHttpAdapter.nextStatusCode = 401;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('session has expired'));
        expect(e.message, isNot(contains('401')));
      }
    });

    test('maps 403 to permission denied message', () async {
      _MockHttpAdapter.nextStatusCode = 403;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('permission'));
        expect(e.message, isNot(contains('403')));
      }
    });

    test('maps 404 to not found message', () async {
      _MockHttpAdapter.nextStatusCode = 404;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('not found'));
        expect(e.message, isNot(contains('404')));
      }
    });

    test('maps 422 to invalid input message', () async {
      _MockHttpAdapter.nextStatusCode = 422;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Invalid input'));
        expect(e.message, isNot(contains('422')));
      }
    });

    test('maps 429 to too many requests message', () async {
      _MockHttpAdapter.nextStatusCode = 429;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Too many requests'));
        expect(e.message, isNot(contains('429')));
      }
    });

    test('maps generic 4xx to user-friendly message', () async {
      _MockHttpAdapter.nextStatusCode = 418;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Something went wrong'));
        expect(e.message, isNot(contains('418')));
      }
    });

    test('maps 500 to server error message', () async {
      _MockHttpAdapter.nextStatusCode = 500;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Server error'));
        expect(e.message, isNot(contains('500')));
      }
    });

    test('maps 502 to server error message', () async {
      _MockHttpAdapter.nextStatusCode = 502;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Server error'));
        expect(e.message, isNot(contains('502')));
      }
    });

    test('maps 503 to server error message', () async {
      _MockHttpAdapter.nextStatusCode = 503;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Server error'));
        expect(e.message, isNot(contains('503')));
      }
    });

    test('does not expose technical details in error messages', () async {
      _MockHttpAdapter.nextStatusCode = 500;
      _MockHttpAdapter.nextBody = '{"error": "NullPointerException at line 42"}';
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, isNot(contains('NullPointerException')));
        expect(e.message, isNot(contains('line 42')));
      }
    });
  });

  group('ErrorInterceptor - Timeout handling', () {
    test('maps connectionTimeout to timeout message', () async {
      _MockHttpAdapter.shouldTimeout = true;
      _MockHttpAdapter.timeoutType = DioExceptionType.connectionTimeout;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Connection timeout'));
      }
    });

    test('maps receiveTimeout to timeout message', () async {
      _MockHttpAdapter.shouldTimeout = true;
      _MockHttpAdapter.timeoutType = DioExceptionType.receiveTimeout;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Connection timeout'));
      }
    });

    test('maps sendTimeout to timeout message', () async {
      _MockHttpAdapter.shouldTimeout = true;
      _MockHttpAdapter.timeoutType = DioExceptionType.sendTimeout;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Connection timeout'));
      }
    });
  });

  group('ErrorInterceptor - Connection errors', () {
    test('maps connectionError to unable to connect message', () async {
      _MockHttpAdapter.shouldTimeout = true;
      _MockHttpAdapter.timeoutType = DioExceptionType.connectionError;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('Unable to connect'));
      }
    });

    test('maps cancel to request cancelled message', () async {
      _MockHttpAdapter.shouldTimeout = true;
      _MockHttpAdapter.timeoutType = DioExceptionType.cancel;
      try {
        await dio.get('/api/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.message, contains('cancelled'));
      }
    });
  });

  group('ErrorInterceptor - message does not expose technical details', () {
    test('error message for 5xx does not contain status code', () async {
      for (final code in [500, 501, 502, 503, 504]) {
        _MockHttpAdapter.nextStatusCode = code;
        try {
          await dio.get('/api/test');
          fail('Should have thrown for $code');
        } on DioException catch (e) {
          expect(e.message, isNot(contains('$code')),
              reason: 'Status code $code should not appear in message');
        }
      }
    });

    test('error message for 4xx does not contain status code', () async {
      for (final code in [400, 401, 403, 404, 422, 429]) {
        _MockHttpAdapter.nextStatusCode = code;
        try {
          await dio.get('/api/test');
          fail('Should have thrown for $code');
        } on DioException catch (e) {
          expect(e.message, isNot(contains('$code')),
              reason: 'Status code $code should not appear in message');
        }
      }
    });
  });
}

/// A mock HTTP adapter that returns configurable responses.
class _MockHttpAdapter implements HttpClientAdapter {
  static int nextStatusCode = 200;
  static String nextBody = '{}';
  static bool shouldTimeout = false;
  static DioExceptionType timeoutType = DioExceptionType.connectionTimeout;

  _MockHttpAdapter() {
    // Reset defaults
    nextStatusCode = 200;
    nextBody = '{}';
    shouldTimeout = false;
    timeoutType = DioExceptionType.connectionTimeout;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (shouldTimeout) {
      throw DioException(
        requestOptions: options,
        type: timeoutType,
      );
    }

    final statusCode = nextStatusCode;
    // Reset for next call
    final body = nextBody;
    nextBody = '{}';

    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
