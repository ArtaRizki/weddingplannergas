import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/rundown.dart';
import '../../../data/repositories/rundown_repository.dart';
import 'rundown_event.dart';
import 'rundown_state.dart';

export 'rundown_event.dart';
export 'rundown_state.dart';

/// BLoC managing rundown list operations: load, add, and delete.
///
/// Handles pessimistic updates — the UI is only updated after a successful
/// API response. On error, the current rundown list is preserved on screen
/// (requirement 9.3, 9.5).
class RundownBloc extends Bloc<RundownEvent, RundownState> {
  final RundownRepository _rundownRepository;

  RundownBloc({
    required RundownRepository rundownRepository,
  })  : _rundownRepository = rundownRepository,
        super(const RundownInitial()) {
    on<LoadRundowns>(_onLoadRundowns);
    on<AddRundown>(_onAddRundown);
    on<DeleteRundown>(_onDeleteRundown);
  }

  /// Handles the [LoadRundowns] event.
  ///
  /// Emits [RundownLoading], then fetches all rundown items from the API.
  /// On success, emits [RundownLoaded] with the fetched list sorted by time ascending.
  /// On failure, emits [RundownError] preserving any previously loaded rundowns.
  Future<void> _onLoadRundowns(
    LoadRundowns event,
    Emitter<RundownState> emit,
  ) async {
    final List<Rundown> previousRundowns = _getPreviousRundowns();

    emit(const RundownLoading());

    try {
      final rundowns = await _rundownRepository.getAll();
      // Sort by time ascending (requirement 9.1)
      rundowns.sort((a, b) => a.time.compareTo(b.time));
      emit(RundownLoaded(rundowns: rundowns));
    } catch (e) {
      emit(RundownError(
        message: _extractErrorMessage(e),
        rundowns: previousRundowns,
      ));
    }
  }

  /// Handles the [AddRundown] event.
  ///
  /// Sends a POST request to create the rundown item. On success, adds the new
  /// item to the current list (sorted by time) and emits [RundownLoaded].
  /// On failure, emits [RundownError] preserving the current rundown list
  /// (requirement 9.3 — retain form data on POST failure is handled by the UI).
  Future<void> _onAddRundown(
    AddRundown event,
    Emitter<RundownState> emit,
  ) async {
    final List<Rundown> currentRundowns = _getPreviousRundowns();

    try {
      final newRundown = await _rundownRepository.create(
        name: event.name,
        time: event.time,
        location: event.location,
        pic: event.pic,
        notes: event.notes,
      );
      final updatedRundowns = [...currentRundowns, newRundown];
      // Sort by time ascending (requirement 9.1)
      updatedRundowns.sort((a, b) => a.time.compareTo(b.time));
      emit(RundownLoaded(rundowns: updatedRundowns));
    } catch (e) {
      emit(RundownError(
        message: _extractErrorMessage(e),
        rundowns: currentRundowns,
      ));
    }
  }

  /// Handles the [DeleteRundown] event.
  ///
  /// Sends a DELETE request to the API. Only removes the rundown item from the
  /// displayed list after a successful response (requirement 9.4).
  /// On failure, emits [RundownError] keeping the item visible in the list
  /// (requirement 9.5).
  Future<void> _onDeleteRundown(
    DeleteRundown event,
    Emitter<RundownState> emit,
  ) async {
    final List<Rundown> currentRundowns = _getPreviousRundowns();

    try {
      await _rundownRepository.delete(event.id);
      final updatedRundowns =
          currentRundowns.where((r) => r.id != event.id).toList();
      emit(RundownLoaded(rundowns: updatedRundowns));
    } catch (e) {
      emit(RundownError(
        message: _extractErrorMessage(e),
        rundowns: currentRundowns,
      ));
    }
  }

  /// Extracts the current rundown list from the current state.
  List<Rundown> _getPreviousRundowns() {
    final currentState = state;
    if (currentState is RundownLoaded) {
      return currentState.rundowns;
    }
    if (currentState is RundownError) {
      return currentState.rundowns;
    }
    return [];
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
    return 'An error occurred. Please try again.';
  }
}
