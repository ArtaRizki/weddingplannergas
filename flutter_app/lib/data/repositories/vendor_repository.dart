import '../api/api_client.dart';
import '../models/vendor.dart';

/// Repository handling vendor data operations with the Laravel API.
///
/// Provides methods to fetch, create, and delete vendors.
/// All methods communicate with the `/api/vendors` endpoint.
class VendorRepository {
  final ApiClient _apiClient;

  VendorRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches all vendors from the API.
  ///
  /// Sends a GET request to `/api/vendors` and returns a list of [Vendor]
  /// parsed from the response envelope's `data` field.
  /// Throws on network or server errors.
  Future<List<Vendor>> getAll() async {
    final response = await _apiClient.get('/api/vendors');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new vendor via the API.
  ///
  /// Sends a POST request to `/api/vendors` with the vendor data.
  /// Returns the created [Vendor] parsed from the response.
  /// Throws on network, server, or validation errors.
  Future<Vendor> create({
    required String name,
    required String category,
    String? phone,
    String? email,
    required double cost,
  }) async {
    final response = await _apiClient.post(
      '/api/vendors',
      data: {
        'name': name,
        'category': category,
        'phone': phone,
        'email': email,
        'cost': cost,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Vendor.fromJson(data);
  }

  /// Deletes a vendor by [id] via the API.
  ///
  /// Sends a DELETE request to `/api/vendors/{id}`.
  /// Throws on network or server errors.
  /// The caller should only remove the vendor from the UI after this
  /// method completes successfully (requirement 8.3).
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/vendors/$id');
  }
}
