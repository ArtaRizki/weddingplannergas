import '../api/api_client.dart';
import '../models/rundown.dart';

/// Repository handling rundown data operations with the Laravel API.
///
/// Provides methods to fetch, create, and delete rundown items.
/// All methods communicate with the `/api/rundowns` endpoint.
class RundownRepository {
  final ApiClient _apiClient;

  RundownRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches all rundown items from the API.
  ///
  /// Sends a GET request to `/api/rundowns` and returns a list of [Rundown]
  /// parsed from the response envelope's `data` field.
  /// Throws on network or server errors.
  Future<List<Rundown>> getAll() async {
    final response = await _apiClient.get('/api/rundowns');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Rundown.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new rundown item via the API.
  ///
  /// Sends a POST request to `/api/rundowns` with the rundown data.
  /// Returns the created [Rundown] parsed from the response.
  /// Throws on network, server, or validation errors.
  Future<Rundown> create({
    required String name,
    required String time,
    String? location,
    String? pic,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/api/rundowns',
      data: {
        'name': name,
        'time': time,
        'location': location,
        'pic': pic,
        'notes': notes,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Rundown.fromJson(data);
  }

  /// Deletes a rundown item by [id] via the API.
  ///
  /// Sends a DELETE request to `/api/rundowns/{id}`.
  /// Throws on network or server errors.
  /// The caller should only remove the rundown item from the UI after this
  /// method completes successfully (requirement 9.5).
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/rundowns/$id');
  }
}
