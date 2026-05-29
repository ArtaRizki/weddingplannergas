import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/phase_repository.dart';
import 'phase_event.dart';
import 'phase_state.dart';

export 'phase_event.dart';
export 'phase_state.dart';

/// BLoC managing phase operations: load all phases and load phase detail.
///
/// Fetches phase data from the [PhaseRepository] and emits appropriate
/// states for the UI to render phase lists and detail views.
class PhaseBloc extends Bloc<PhaseEvent, PhaseState> {
  final PhaseRepository _phaseRepository;

  PhaseBloc({
    required PhaseRepository phaseRepository,
  })  : _phaseRepository = phaseRepository,
        super(const PhaseInitial()) {
    on<LoadPhases>(_onLoadPhases);
    on<LoadPhaseDetail>(_onLoadPhaseDetail);
  }

  /// Handles the [LoadPhases] event.
  ///
  /// Emits [PhaseLoading], then fetches all phases from the API.
  /// On success, emits [PhasesLoaded] with phases sorted by sort order.
  /// On failure, emits [PhaseError] with a user-friendly message.
  Future<void> _onLoadPhases(
    LoadPhases event,
    Emitter<PhaseState> emit,
  ) async {
    emit(const PhaseLoading());

    try {
      final phases = await _phaseRepository.getAll();
      // Sort phases by their sort order
      phases.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      emit(PhasesLoaded(phases: phases));
    } catch (e) {
      emit(PhaseError(message: _extractErrorMessage(e)));
    }
  }

  /// Handles the [LoadPhaseDetail] event.
  ///
  /// Emits [PhaseLoading], then fetches the phase detail with its tasks.
  /// On success, emits [PhaseDetailLoaded] with the phase and its tasks
  /// ordered by sort order. On failure, emits [PhaseError].
  Future<void> _onLoadPhaseDetail(
    LoadPhaseDetail event,
    Emitter<PhaseState> emit,
  ) async {
    emit(const PhaseLoading());

    try {
      final detail = await _phaseRepository.getDetail(event.phaseId);
      // Tasks are already ordered by sort order from the API,
      // but ensure sorting client-side as well
      final sortedTasks = List.of(detail.tasks)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      emit(PhaseDetailLoaded(phase: detail.phase, tasks: sortedTasks));
    } catch (e) {
      emit(PhaseError(message: _extractErrorMessage(e)));
    }
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
    return 'Failed to load phase data. Please try again.';
  }
}
