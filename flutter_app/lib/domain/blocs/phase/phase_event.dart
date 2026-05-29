import 'package:equatable/equatable.dart';

/// Events for the [PhaseBloc].
abstract class PhaseEvent extends Equatable {
  const PhaseEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all phases from the API.
class LoadPhases extends PhaseEvent {
  const LoadPhases();
}

/// Triggered to load a single phase's detail with its tasks.
class LoadPhaseDetail extends PhaseEvent {
  final int phaseId;

  const LoadPhaseDetail({required this.phaseId});

  @override
  List<Object?> get props => [phaseId];
}
