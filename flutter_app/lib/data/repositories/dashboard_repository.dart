import '../api/api_client.dart';
import '../models/dashboard_data.dart';

/// Repository handling dashboard data retrieval from the Laravel API.
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches dashboard summary data from the API.
  ///
  /// Sends a GET request to `/api/dashboard` and returns [DashboardData]
  /// parsed from the response envelope's `data` field.
  /// Throws on network or server errors.
  Future<DashboardData> getDashboardData() async {
    final response = await _apiClient.get('/api/dashboard');
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardData.fromJson(data);
  }
}
