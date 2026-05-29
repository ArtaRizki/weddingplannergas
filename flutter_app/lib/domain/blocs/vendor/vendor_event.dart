import 'package:equatable/equatable.dart';

/// Events for the [VendorBloc].
abstract class VendorEvent extends Equatable {
  const VendorEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all vendors from the API.
class LoadVendors extends VendorEvent {
  const LoadVendors();
}

/// Triggered to add a new vendor via the API.
class AddVendor extends VendorEvent {
  final String name;
  final String category;
  final String? phone;
  final String? email;
  final double cost;

  const AddVendor({
    required this.name,
    required this.category,
    this.phone,
    this.email,
    required this.cost,
  });

  @override
  List<Object?> get props => [name, category, phone, email, cost];
}

/// Triggered to delete a vendor by ID via the API.
///
/// The vendor is only removed from the displayed list after a successful
/// API response (requirement 8.3).
class DeleteVendor extends VendorEvent {
  final int id;

  const DeleteVendor({required this.id});

  @override
  List<Object?> get props => [id];
}
