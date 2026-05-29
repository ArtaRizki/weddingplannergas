import 'package:equatable/equatable.dart';

import '../../../data/models/rundown.dart';

/// States for the [RundownBloc].
abstract class RundownState extends Equatable {
  const RundownState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any rundown data has been requested.
class RundownInitial extends RundownState {
  const RundownInitial();
}

/// Rundown data is currently being loaded from the API.
class RundownLoading extends RundownState {
  const RundownLoading();
}

/// Rundown data has been successfully loaded.
class RundownLoaded extends RundownState {
  /// The list of rundown items retrieved from the API.
  final List<Rundown> rundowns;

  const RundownLoaded({required this.rundowns});

  @override
  List<Object?> get props => [rundowns];
}

/// An error occurred while performing a rundown operation.
///
/// If [rundowns] is non-empty, it contains the last successfully loaded
/// rundown list that should still be displayed to the user (requirement 9.5).
class RundownError extends RundownState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  /// Previously loaded rundown list to preserve on screen during errors.
  final List<Rundown> rundowns;

  const RundownError({
    required this.message,
    this.rundowns = const [],
  });

  @override
  List<Object?> get props => [message, rundowns];
}
