import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/vendor.dart';
import '../../../data/repositories/vendor_repository.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';

export 'vendor_event.dart';
export 'vendor_state.dart';

/// BLoC managing vendor list operations: load, add, and delete.
///
/// Handles pessimistic updates — the UI is only updated after a successful
/// API response. On error, the current vendor list is preserved on screen
/// (requirement 8.6).
class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final VendorRepository _vendorRepository;

  VendorBloc({
    required VendorRepository vendorRepository,
  })  : _vendorRepository = vendorRepository,
        super(const VendorInitial()) {
    on<LoadVendors>(_onLoadVendors);
    on<AddVendor>(_onAddVendor);
    on<DeleteVendor>(_onDeleteVendor);
  }

  /// Handles the [LoadVendors] event.
  ///
  /// Emits [VendorLoading], then fetches all vendors from the API.
  /// On success, emits [VendorLoaded] with the fetched list.
  /// On failure, emits [VendorError] preserving any previously loaded vendors.
  Future<void> _onLoadVendors(
    LoadVendors event,
    Emitter<VendorState> emit,
  ) async {
    final List<Vendor> previousVendors = _getPreviousVendors();

    emit(const VendorLoading());

    try {
      final vendors = await _vendorRepository.getAll();
      emit(VendorLoaded(vendors: vendors));
    } catch (e) {
      emit(VendorError(
        message: _extractErrorMessage(e),
        vendors: previousVendors,
      ));
    }
  }

  /// Handles the [AddVendor] event.
  ///
  /// Sends a POST request to create the vendor. On success, adds the new
  /// vendor to the current list and emits [VendorLoaded].
  /// On failure, emits [VendorError] preserving the current vendor list
  /// (requirement 8.6).
  Future<void> _onAddVendor(
    AddVendor event,
    Emitter<VendorState> emit,
  ) async {
    final List<Vendor> currentVendors = _getPreviousVendors();

    try {
      final newVendor = await _vendorRepository.create(
        name: event.name,
        category: event.category,
        phone: event.phone,
        email: event.email,
        cost: event.cost,
      );
      emit(VendorLoaded(vendors: [...currentVendors, newVendor]));
    } catch (e) {
      emit(VendorError(
        message: _extractErrorMessage(e),
        vendors: currentVendors,
      ));
    }
  }

  /// Handles the [DeleteVendor] event.
  ///
  /// Sends a DELETE request to the API. Only removes the vendor from the
  /// displayed list after a successful response (requirement 8.3).
  /// On failure, emits [VendorError] preserving the current vendor list
  /// (requirement 8.6).
  Future<void> _onDeleteVendor(
    DeleteVendor event,
    Emitter<VendorState> emit,
  ) async {
    final List<Vendor> currentVendors = _getPreviousVendors();

    try {
      await _vendorRepository.delete(event.id);
      final updatedVendors =
          currentVendors.where((v) => v.id != event.id).toList();
      emit(VendorLoaded(vendors: updatedVendors));
    } catch (e) {
      emit(VendorError(
        message: _extractErrorMessage(e),
        vendors: currentVendors,
      ));
    }
  }

  /// Extracts the current vendor list from the current state.
  List<Vendor> _getPreviousVendors() {
    final currentState = state;
    if (currentState is VendorLoaded) {
      return currentState.vendors;
    }
    if (currentState is VendorError) {
      return currentState.vendors;
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
