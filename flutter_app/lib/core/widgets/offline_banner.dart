import 'dart:async';

import 'package:flutter/material.dart';

import '../network/connectivity_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// A banner widget that displays a visible offline indicator when the device
/// has no network connectivity.
///
/// Place this widget at the top of screens (e.g., inside a Column or below
/// an AppBar) to inform users when they are offline.
///
/// The banner automatically shows/hides based on the [ConnectivityService]
/// status stream.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     const OfflineBanner(),
///     Expanded(child: content),
///   ],
/// )
/// ```
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({
    super.key,
    this.connectivityService,
  });

  /// Optional [ConnectivityService] instance. If not provided, uses the
  /// singleton [ConnectivityService.instance].
  final ConnectivityService? connectivityService;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late ConnectivityService _service;
  late ConnectivityStatus _status;
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  void initState() {
    super.initState();
    _service = widget.connectivityService ?? ConnectivityService.instance;
    _status = _service.status;
    _subscription = _service.statusStream.listen((status) {
      if (mounted) {
        setState(() => _status = status);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == ConnectivityStatus.online) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            color: AppTheme.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'No internet connection',
            style: AppTypography.body.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A wrapper widget that provides connectivity-aware behavior to its child.
///
/// When offline:
/// - Displays the [OfflineBanner] at the top
/// - Optionally disables data submission controls via [disableOnOffline]
///
/// Usage:
/// ```dart
/// ConnectivityAwareWrapper(
///   child: MyScreen(),
/// )
/// ```
class ConnectivityAwareWrapper extends StatefulWidget {
  const ConnectivityAwareWrapper({
    super.key,
    required this.child,
    this.connectivityService,
  });

  /// The child widget to wrap with connectivity awareness.
  final Widget child;

  /// Optional [ConnectivityService] instance. If not provided, uses the
  /// singleton [ConnectivityService.instance].
  final ConnectivityService? connectivityService;

  @override
  State<ConnectivityAwareWrapper> createState() =>
      _ConnectivityAwareWrapperState();
}

class _ConnectivityAwareWrapperState extends State<ConnectivityAwareWrapper> {
  late ConnectivityService _service;
  late ConnectivityStatus _status;
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  void initState() {
    super.initState();
    _service = widget.connectivityService ?? ConnectivityService.instance;
    _status = _service.status;
    _subscription = _service.statusStream.listen((status) {
      if (mounted) {
        setState(() => _status = status);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityScope(
      status: _status,
      child: Column(
        children: [
          OfflineBanner(connectivityService: _service),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

/// An InheritedWidget that provides the current [ConnectivityStatus]
/// to descendant widgets.
///
/// Use [ConnectivityScope.of] to access the current status and determine
/// whether to disable data submission controls.
///
/// Usage:
/// ```dart
/// final status = ConnectivityScope.of(context);
/// final isOffline = status == ConnectivityStatus.offline;
///
/// NeoButton(
///   onPressed: isOffline ? null : _submitForm,
///   label: 'Submit',
///   isDisabled: isOffline,
/// )
/// ```
class ConnectivityScope extends InheritedWidget {
  const ConnectivityScope({
    super.key,
    required this.status,
    required super.child,
  });

  /// The current connectivity status.
  final ConnectivityStatus status;

  /// Whether the device is currently offline.
  bool get isOffline => status == ConnectivityStatus.offline;

  /// Whether the device is currently online.
  bool get isOnline => status == ConnectivityStatus.online;

  /// Returns the nearest [ConnectivityScope] ancestor's status,
  /// or [ConnectivityStatus.online] if none is found.
  static ConnectivityStatus of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ConnectivityScope>();
    return scope?.status ?? ConnectivityStatus.online;
  }

  /// Returns whether the device is currently offline.
  /// Convenience method for use in widget build methods.
  static bool isDeviceOffline(BuildContext context) {
    return of(context) == ConnectivityStatus.offline;
  }

  @override
  bool updateShouldNotify(ConnectivityScope oldWidget) {
    return status != oldWidget.status;
  }
}
