import 'package:equatable/equatable.dart';

/// Events for the [DashboardBloc].
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load or refresh dashboard data from the API.
///
/// Used both for initial load and pull-to-refresh.
class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}
