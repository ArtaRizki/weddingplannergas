import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dashboard_data.dart';
import '../../../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

/// BLoC managing dashboard data loading and refresh.
///
/// Handles [LoadDashboard] events for both initial load and pull-to-refresh.
/// On refresh failure, retains previously displayed data in the error state
/// (requirement 3.8).
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc({
    required DashboardRepository dashboardRepository,
  })  : _dashboardRepository = dashboardRepository,
        super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  /// Handles the [LoadDashboard] event.
  ///
  /// Emits [DashboardLoading], then attempts to fetch data from the API.
  /// On success, emits [DashboardLoaded] with the fetched data.
  /// On failure, emits [DashboardError] with the error message and any
  /// previously loaded data so the UI can continue displaying it.
  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Capture previously loaded data before emitting loading state
    final DashboardData? previousData = _getPreviousData();

    emit(const DashboardLoading());

    try {
      final data = await _dashboardRepository.getDashboardData();
      emit(DashboardLoaded(data: data));
    } catch (e) {
      emit(DashboardError(
        message: _extractErrorMessage(e),
        previousData: previousData,
      ));
    }
  }

  /// Extracts previously loaded dashboard data from the current state.
  DashboardData? _getPreviousData() {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      return currentState.data;
    }
    if (currentState is DashboardError) {
      return currentState.previousData;
    }
    return null;
  }

  /// Extracts a user-friendly error message from an exception.
  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      final message = error.toString();
      // DioException messages are already user-friendly thanks to ErrorInterceptor
      if (message.contains('Exception: ')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }
    return 'Failed to load dashboard data. Please try again.';
  }
}
