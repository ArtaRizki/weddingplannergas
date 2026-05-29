import 'package:equatable/equatable.dart';

import '../../../data/models/wedding.dart';

/// States for the [SettingsBloc].
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any settings data has been requested.
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Settings data is currently being loaded from the API.
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Settings data has been successfully loaded.
///
/// Contains the current wedding settings.
class SettingsLoaded extends SettingsState {
  /// The current wedding settings.
  final Wedding settings;

  const SettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// Settings have been successfully updated.
///
/// Contains the updated wedding settings and a success message
/// for displaying a confirmation to the user (requirement 10.2).
class SettingsSuccess extends SettingsState {
  /// The updated wedding settings.
  final Wedding settings;

  /// A user-friendly success message.
  final String message;

  const SettingsSuccess({
    required this.settings,
    this.message = 'Settings updated successfully.',
  });

  @override
  List<Object?> get props => [settings, message];
}

/// An error occurred during a settings operation.
///
/// If [settings] is non-null, it contains the last successfully loaded
/// settings that should still be displayed to the user (requirement 10.5).
class SettingsError extends SettingsState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  /// Previously loaded settings to preserve on screen during errors.
  /// Null if no data was previously loaded (e.g., initial load failure).
  final Wedding? settings;

  const SettingsError({
    required this.message,
    this.settings,
  });

  @override
  List<Object?> get props => [message, settings];
}
