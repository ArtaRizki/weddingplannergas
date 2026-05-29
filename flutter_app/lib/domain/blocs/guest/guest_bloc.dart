import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/guest.dart';
import '../../../data/repositories/guest_repository.dart';
import 'guest_event.dart';
import 'guest_state.dart';

export 'guest_event.dart';
export 'guest_state.dart';

/// BLoC managing guest list operations: load, add, and delete.
///
/// Handles pessimistic updates — the UI is only updated after a successful
/// API response. On error, the current guest list is preserved on screen
/// (requirement 5.6).
class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository _guestRepository;

  GuestBloc({
    required GuestRepository guestRepository,
  })  : _guestRepository = guestRepository,
        super(const GuestInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<AddGuest>(_onAddGuest);
    on<DeleteGuest>(_onDeleteGuest);
  }

  /// Handles the [LoadGuests] event.
  ///
  /// Emits [GuestLoading], then fetches all guests from the API.
  /// On success, emits [GuestLoaded] with the fetched list.
  /// On failure, emits [GuestError] preserving any previously loaded guests.
  Future<void> _onLoadGuests(
    LoadGuests event,
    Emitter<GuestState> emit,
  ) async {
    final List<Guest> previousGuests = _getPreviousGuests();

    emit(const GuestLoading());

    try {
      final guests = await _guestRepository.getAll();
      emit(GuestLoaded(guests: guests));
    } catch (e) {
      emit(GuestError(
        message: _extractErrorMessage(e),
        guests: previousGuests,
      ));
    }
  }

  /// Handles the [AddGuest] event.
  ///
  /// Sends a POST request to create the guest. On success, adds the new
  /// guest to the current list and emits [GuestLoaded].
  /// On failure, emits [GuestError] preserving the current guest list
  /// (requirement 5.6).
  Future<void> _onAddGuest(
    AddGuest event,
    Emitter<GuestState> emit,
  ) async {
    final List<Guest> currentGuests = _getPreviousGuests();

    try {
      final newGuest = await _guestRepository.create(
        name: event.name,
        side: event.side,
        phone: event.phone,
        email: event.email,
        status: event.status,
      );
      emit(GuestLoaded(guests: [...currentGuests, newGuest]));
    } catch (e) {
      emit(GuestError(
        message: _extractErrorMessage(e),
        guests: currentGuests,
      ));
    }
  }

  /// Handles the [DeleteGuest] event.
  ///
  /// Sends a DELETE request to the API. Only removes the guest from the
  /// displayed list after a successful response (requirement 5.4).
  /// On failure, emits [GuestError] preserving the current guest list
  /// (requirement 5.6).
  Future<void> _onDeleteGuest(
    DeleteGuest event,
    Emitter<GuestState> emit,
  ) async {
    final List<Guest> currentGuests = _getPreviousGuests();

    try {
      await _guestRepository.delete(event.id);
      final updatedGuests =
          currentGuests.where((g) => g.id != event.id).toList();
      emit(GuestLoaded(guests: updatedGuests));
    } catch (e) {
      emit(GuestError(
        message: _extractErrorMessage(e),
        guests: currentGuests,
      ));
    }
  }

  /// Extracts the current guest list from the current state.
  List<Guest> _getPreviousGuests() {
    final currentState = state;
    if (currentState is GuestLoaded) {
      return currentState.guests;
    }
    if (currentState is GuestError) {
      return currentState.guests;
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
