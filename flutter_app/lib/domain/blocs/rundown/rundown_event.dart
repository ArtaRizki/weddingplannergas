import 'package:equatable/equatable.dart';

/// Events for the [RundownBloc].
abstract class RundownEvent extends Equatable {
  const RundownEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all rundown items from the API.
class LoadRundowns extends RundownEvent {
  const LoadRundowns();
}

/// Triggered to add a new rundown item via the API.
class AddRundown extends RundownEvent {
  final String name;
  final String time;
  final String? location;
  final String? pic;
  final String? notes;

  const AddRundown({
    required this.name,
    required this.time,
    this.location,
    this.pic,
    this.notes,
  });

  @override
  List<Object?> get props => [name, time, location, pic, notes];
}

/// Triggered to delete a rundown item by ID via the API.
///
/// The rundown item is only removed from the displayed list after a successful
/// API response (requirement 9.5).
class DeleteRundown extends RundownEvent {
  final int id;

  const DeleteRundown({required this.id});

  @override
  List<Object?> get props => [id];
}
