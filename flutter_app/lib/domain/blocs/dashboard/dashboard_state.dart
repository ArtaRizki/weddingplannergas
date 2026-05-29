import 'package:equatable/equatable.dart';

import '../../../data/models/dashboard_data.dart';

/// States for the [DashboardBloc].
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any dashboard data has been requested.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Dashboard data is currently being loaded from the API.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Dashboard data has been successfully loaded.
class DashboardLoaded extends DashboardState {
  /// The dashboard data retrieved from the API.
  final DashboardData data;

  const DashboardLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

/// An error occurred while loading dashboard data.
///
/// If [previousData] is non-null, it contains the last successfully
/// loaded data that should still be displayed to the user (requirement 3.8).
class DashboardError extends DashboardState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  /// Previously loaded dashboard data to retain on screen during errors.
  /// Null if no data was previously loaded (e.g., initial load failure).
  final DashboardData? previousData;

  const DashboardError({
    required this.message,
    this.previousData,
  });

  @override
  List<Object?> get props => [message, previousData];
}
