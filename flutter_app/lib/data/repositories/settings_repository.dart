import '../api/api_client.dart';
import '../models/wedding.dart';

/// Repository handling wedding settings retrieval and update via the Laravel API.
///
/// Provides methods to get current wedding settings and update them
/// via the `/api/settings` endpoints.
class SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches the current wedding settings from the API.
  ///
  /// Sends a GET request to `/api/settings` and returns a [Wedding]
  /// parsed from the response envelope's `data` field.
  Future<Wedding> getSettings() async {
    final response = await _apiClient.get('/api/settings');
    final data = response.data['data'] as Map<String, dynamic>;
    return Wedding.fromJson(data);
  }

  /// Updates the wedding settings.
  ///
  /// Sends a PUT request to `/api/settings` with the updated
  /// [groomName], [brideName], [weddingDate], [location], and [totalBudget].
  /// Returns the updated [Wedding] from the response.
  Future<Wedding> updateSettings({
    required String groomName,
    required String brideName,
    DateTime? weddingDate,
    String? location,
    required double totalBudget,
  }) async {
    final response = await _apiClient.put(
      '/api/settings',
      data: {
        'groom_name': groomName,
        'bride_name': brideName,
        'wedding_date': weddingDate?.toIso8601String().split('T').first,
        'location': location,
        'total_budget': totalBudget,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Wedding.fromJson(data);
  }
}
