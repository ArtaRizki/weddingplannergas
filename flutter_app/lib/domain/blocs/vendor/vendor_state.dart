import 'package:equatable/equatable.dart';

import '../../../data/models/vendor.dart';

/// States for the [VendorBloc].
abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any vendor data has been requested.
class VendorInitial extends VendorState {
  const VendorInitial();
}

/// Vendor data is currently being loaded from the API.
class VendorLoading extends VendorState {
  const VendorLoading();
}

/// Vendor data has been successfully loaded.
class VendorLoaded extends VendorState {
  /// The list of vendors retrieved from the API.
  final List<Vendor> vendors;

  const VendorLoaded({required this.vendors});

  @override
  List<Object?> get props => [vendors];
}

/// An error occurred while performing a vendor operation.
///
/// If [vendors] is non-empty, it contains the last successfully loaded
/// vendor list that should still be displayed to the user (requirement 8.6).
class VendorError extends VendorState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  /// Previously loaded vendor list to preserve on screen during errors.
  final List<Vendor> vendors;

  const VendorError({
    required this.message,
    this.vendors = const [],
  });

  @override
  List<Object?> get props => [message, vendors];
}
