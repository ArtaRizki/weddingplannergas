import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planner/core/network/connectivity_service.dart';

/// A fake [Connectivity] implementation for testing.
///
/// Does not extend [Connectivity] directly since it has no unnamed constructor.
/// Instead, we use a wrapper approach in the service.
class FakeConnectivity implements Connectivity {
  final StreamController<ConnectivityResult> _controller =
      StreamController<ConnectivityResult>.broadcast();

  ConnectivityResult _currentResult = ConnectivityResult.wifi;

  void setConnectivity(ConnectivityResult result) {
    _currentResult = result;
    _controller.add(result);
  }

  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return _currentResult;
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ConnectivityService', () {
    late FakeConnectivity fakeConnectivity;
    late ConnectivityService service;

    setUp(() {
      fakeConnectivity = FakeConnectivity();
      service = ConnectivityService(connectivity: fakeConnectivity);
    });

    tearDown(() {
      service.dispose();
      fakeConnectivity.dispose();
    });

    test('initializes with online status when WiFi is available', () async {
      fakeConnectivity._currentResult = ConnectivityResult.wifi;
      await service.init();

      expect(service.status, ConnectivityStatus.online);
      expect(service.isOnline, isTrue);
      expect(service.isOffline, isFalse);
    });

    test('initializes with online status when mobile is available', () async {
      fakeConnectivity._currentResult = ConnectivityResult.mobile;
      await service.init();

      expect(service.status, ConnectivityStatus.online);
      expect(service.isOnline, isTrue);
    });

    test('initializes with offline status when no connectivity', () async {
      fakeConnectivity._currentResult = ConnectivityResult.none;
      await service.init();

      expect(service.status, ConnectivityStatus.offline);
      expect(service.isOffline, isTrue);
      expect(service.isOnline, isFalse);
    });

    test('emits offline when connectivity is lost', () async {
      fakeConnectivity._currentResult = ConnectivityResult.wifi;
      await service.init();

      expect(service.isOnline, isTrue);

      // Expect the stream to emit offline
      expectLater(
        service.statusStream,
        emits(ConnectivityStatus.offline),
      );

      fakeConnectivity.setConnectivity(ConnectivityResult.none);
    });

    test('emits online when connectivity is restored', () async {
      fakeConnectivity._currentResult = ConnectivityResult.none;
      await service.init();

      expect(service.isOffline, isTrue);

      expectLater(
        service.statusStream,
        emits(ConnectivityStatus.online),
      );

      fakeConnectivity.setConnectivity(ConnectivityResult.wifi);
    });

    test('does not emit when status does not change', () async {
      fakeConnectivity._currentResult = ConnectivityResult.wifi;
      await service.init();

      // Stream should not emit anything since status stays online
      final emissions = <ConnectivityStatus>[];
      service.statusStream.listen(emissions.add);

      // WiFi to mobile is still online — no status change
      fakeConnectivity.setConnectivity(ConnectivityResult.mobile);

      // Give time for potential emission
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emissions, isEmpty);
    });

    test('transitions through multiple status changes', () async {
      fakeConnectivity._currentResult = ConnectivityResult.wifi;
      await service.init();

      final emissions = <ConnectivityStatus>[];
      service.statusStream.listen(emissions.add);

      // Go offline
      fakeConnectivity.setConnectivity(ConnectivityResult.none);
      await Future.delayed(const Duration(milliseconds: 10));

      // Come back online
      fakeConnectivity.setConnectivity(ConnectivityResult.mobile);
      await Future.delayed(const Duration(milliseconds: 10));

      // Go offline again
      fakeConnectivity.setConnectivity(ConnectivityResult.none);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(emissions, [
        ConnectivityStatus.offline,
        ConnectivityStatus.online,
        ConnectivityStatus.offline,
      ]);
    });

    test('initializes with online status for ethernet', () async {
      fakeConnectivity._currentResult = ConnectivityResult.ethernet;
      await service.init();

      expect(service.isOnline, isTrue);
    });

    test('initializes with online status for bluetooth', () async {
      fakeConnectivity._currentResult = ConnectivityResult.bluetooth;
      await service.init();

      expect(service.isOnline, isTrue);
    });
  });
}
