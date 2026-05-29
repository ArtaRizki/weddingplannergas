import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Represents the current network connectivity status.
enum ConnectivityStatus {
  /// Device is connected to a network (WiFi, mobile, ethernet, etc.).
  online,

  /// Device has no network connectivity.
  offline,
}

/// Service that monitors network connectivity using [connectivity_plus].
///
/// Exposes:
/// - [status] — current connectivity status
/// - [statusStream] — a broadcast stream of connectivity status changes
/// - [isOnline] — convenience getter for checking if currently online
///
/// Usage:
/// ```dart
/// final service = ConnectivityService();
/// await service.init();
///
/// // Check current status
/// if (service.isOnline) { ... }
///
/// // Listen to changes
/// service.statusStream.listen((status) {
///   if (status == ConnectivityStatus.offline) {
///     // Show offline indicator
///   }
/// });
///
/// // Dispose when done
/// service.dispose();
/// ```
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Singleton instance for app-wide usage.
  static ConnectivityService? _instance;

  /// Returns the singleton instance of [ConnectivityService].
  /// Creates one with default configuration if not yet initialized.
  static ConnectivityService get instance {
    _instance ??= ConnectivityService();
    return _instance!;
  }

  /// Creates and sets the singleton with a custom [Connectivity] instance.
  /// Useful for testing or custom configuration.
  static void createInstance({Connectivity? connectivity}) {
    _instance = ConnectivityService(connectivity: connectivity);
  }

  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityStatus _status = ConnectivityStatus.online;

  /// The current connectivity status.
  ConnectivityStatus get status => _status;

  /// Whether the device currently has network connectivity.
  bool get isOnline => _status == ConnectivityStatus.online;

  /// Whether the device currently has no network connectivity.
  bool get isOffline => _status == ConnectivityStatus.offline;

  /// A broadcast stream of connectivity status changes.
  ///
  /// Emits [ConnectivityStatus.offline] when the device loses connectivity,
  /// and [ConnectivityStatus.online] when connectivity is restored.
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Initializes the service by checking the current connectivity
  /// and subscribing to connectivity changes.
  ///
  /// Must be called before using [status] or [statusStream].
  Future<void> init() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _status = _mapResult(result);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        final newStatus = _mapResult(result);
        if (newStatus != _status) {
          _status = newStatus;
          _statusController.add(_status);
        }
      },
    );
  }

  /// Maps a [ConnectivityResult] to a [ConnectivityStatus].
  ///
  /// Returns [ConnectivityStatus.offline] when the result is
  /// [ConnectivityResult.none]. Any other result means the device has
  /// some form of connectivity.
  ConnectivityStatus _mapResult(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  /// Disposes the service and cancels the connectivity subscription.
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
