import '../api/api_client.dart';
import '../models/guest.dart';

/// Repository handling guest data operations with the Laravel API.
///
/// Provides methods to fetch, create, and delete guests.
/// All methods communicate with the `/api/guests` endpoint.
class GuestRepository {
  final ApiClient _apiClient;

  GuestRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches all guests from the API.
  ///
  /// Sends a GET request to `/api/guests` and returns a list of [Guest]
  /// parsed from the response envelope's `data` field.
  /// Throws on network or server errors.
  Future<List<Guest>> getAll() async {
    final response = await _apiClient.get('/api/guests');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Guest.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new guest via the API.
  ///
  /// Sends a POST request to `/api/guests` with the guest data.
  /// Returns the created [Guest] parsed from the response.
  /// Throws on network, server, or validation errors.
  Future<Guest> create({
    required String name,
    required String side,
    String? phone,
    String? email,
    required String status,
  }) async {
    final response = await _apiClient.post(
      '/api/guests',
      data: {
        'name': name,
        'side': side,
        'phone': phone,
        'email': email,
        'status': status,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Guest.fromJson(data);
  }

  /// Deletes a guest by [id] via the API.
  ///
  /// Sends a DELETE request to `/api/guests/{id}`.
  /// Throws on network or server errors.
  /// The caller should only remove the guest from the UI after this
  /// method completes successfully (requirement 5.4).
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/guests/$id');
  }
}
