import 'package:equatable/equatable.dart';

/// Events for the [GuestBloc].
abstract class GuestEvent extends Equatable {
  const GuestEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all guests from the API.
class LoadGuests extends GuestEvent {
  const LoadGuests();
}

/// Triggered to add a new guest via the API.
class AddGuest extends GuestEvent {
  final String name;
  final String side;
  final String? phone;
  final String? email;
  final String status;

  const AddGuest({
    required this.name,
    required this.side,
    this.phone,
    this.email,
    required this.status,
  });

  @override
  List<Object?> get props => [name, side, phone, email, status];
}

/// Triggered to delete a guest by ID via the API.
///
/// The guest is only removed from the displayed list after a successful
/// API response (requirement 5.4).
class DeleteGuest extends GuestEvent {
  final int id;

  const DeleteGuest({required this.id});

  @override
  List<Object?> get props => [id];
}
