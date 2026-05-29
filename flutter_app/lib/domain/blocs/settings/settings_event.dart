import 'package:equatable/equatable.dart';

/// Events for the [SettingsBloc].
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load the current wedding settings from the API.
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Triggered to update the wedding settings.
class UpdateSettings extends SettingsEvent {
  final String groomName;
  final String brideName;
  final DateTime? weddingDate;
  final String? location;
  final double totalBudget;

  const UpdateSettings({
    required this.groomName,
    required this.brideName,
    this.weddingDate,
    this.location,
    required this.totalBudget,
  });

  @override
  List<Object?> get props => [groomName, brideName, weddingDate, location, totalBudget];
}
