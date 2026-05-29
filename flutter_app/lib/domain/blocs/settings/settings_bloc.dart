import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/wedding.dart';
import '../../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

export 'settings_event.dart';
export 'settings_state.dart';

/// BLoC managing wedding settings load and update operations.
///
/// Handles [LoadSettings] and [UpdateSettings] events.
/// On update failure, preserves the user-entered data on screen
/// (requirement 10.5). On update success, emits [SettingsSuccess]
/// with a confirmation message (requirement 10.2).
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
  }

  /// Handles the [LoadSettings] event.
  ///
  /// Emits [SettingsLoading], then fetches settings from the API.
  /// On success, emits [SettingsLoaded]. On failure, emits [SettingsError]
  /// with any previously loaded settings preserved.
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final Wedding? previousSettings = _getPreviousSettings();

    emit(const SettingsLoading());

    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(
        message: _extractErrorMessage(e),
        settings: previousSettings,
      ));
    }
  }

  /// Handles the [UpdateSettings] event.
  ///
  /// Sends an update request to the API. On success, emits [SettingsSuccess]
  /// with the updated settings and a confirmation message.
  /// On failure, emits [SettingsError] preserving the previous settings
  /// so the user-entered data is retained on screen.
  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final Wedding? previousSettings = _getPreviousSettings();

    emit(const SettingsLoading());

    try {
      final updatedSettings = await _settingsRepository.updateSettings(
        groomName: event.groomName,
        brideName: event.brideName,
        weddingDate: event.weddingDate,
        location: event.location,
        totalBudget: event.totalBudget,
      );
      emit(SettingsSuccess(
        settings: updatedSettings,
        message: 'Settings updated successfully.',
      ));
    } catch (e) {
      emit(SettingsError(
        message: _extractErrorMessage(e),
        settings: previousSettings,
      ));
    }
  }

  /// Extracts previously loaded settings from the current state.
  Wedding? _getPreviousSettings() {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      return currentState.settings;
    }
    if (currentState is SettingsSuccess) {
      return currentState.settings;
    }
    if (currentState is SettingsError) {
      return currentState.settings;
    }
    return null;
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
    return 'Failed to complete settings operation. Please try again.';
  }
}
