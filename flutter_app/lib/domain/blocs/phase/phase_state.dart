import 'package:equatable/equatable.dart';

import '../../../data/models/phase.dart';
import '../../../data/models/task.dart';

/// States for the [PhaseBloc].
abstract class PhaseState extends Equatable {
  const PhaseState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any phase data has been requested.
class PhaseInitial extends PhaseState {
  const PhaseInitial();
}

/// Phases are currently being loaded from the API.
class PhaseLoading extends PhaseState {
  const PhaseLoading();
}

/// All phases have been successfully loaded.
class PhasesLoaded extends PhaseState {
  /// All phases sorted by their sort order.
  final List<Phase> phases;

  const PhasesLoaded({required this.phases});

  @override
  List<Object?> get props => [phases];
}

/// A single phase's detail (with tasks) has been successfully loaded.
class PhaseDetailLoaded extends PhaseState {
  /// The phase metadata.
  final Phase phase;

  /// Tasks belonging to this phase, ordered by sort order.
  final List<Task> tasks;

  const PhaseDetailLoaded({
    required this.phase,
    required this.tasks,
  });

  @override
  List<Object?> get props => [phase, tasks];
}

/// An error occurred while performing a phase operation.
class PhaseError extends PhaseState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  const PhaseError({required this.message});

  @override
  List<Object?> get props => [message];
}
