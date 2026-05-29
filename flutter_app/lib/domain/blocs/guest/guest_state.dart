import 'package:equatable/equatable.dart';

import '../../../data/models/guest.dart';

/// States for the [GuestBloc].
abstract class GuestState extends Equatable {
  const GuestState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any guest data has been requested.
class GuestInitial extends GuestState {
  const GuestInitial();
}

/// Guest data is currently being loaded from the API.
class GuestLoading extends GuestState {
  const GuestLoading();
}

/// Guest data has been successfully loaded.
class GuestLoaded extends GuestState {
  /// The list of guests retrieved from the API.
  final List<Guest> guests;

  const GuestLoaded({required this.guests});

  @override
  List<Object?> get props => [guests];
}

/// An error occurred while performing a guest operation.
///
/// If [guests] is non-empty, it contains the last successfully loaded
/// guest list that should still be displayed to the user (requirement 5.6).
class GuestError extends GuestState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  /// Previously loaded guest list to preserve on screen during errors.
  final List<Guest> guests;

  const GuestError({
    required this.message,
    this.guests = const [],
  });

  @override
  List<Object?> get props => [message, guests];
}
