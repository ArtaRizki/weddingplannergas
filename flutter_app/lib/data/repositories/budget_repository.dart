import '../api/api_client.dart';
import '../models/budget.dart';

/// Repository handling budget CRUD operations with the Laravel API.
///
/// Provides methods to list, create, update, and delete budget entries
/// via the `/api/budgets` endpoints.
class BudgetRepository {
  final ApiClient _apiClient;

  BudgetRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches all budget entries from the API.
  ///
  /// Sends a GET request to `/api/budgets` and returns a list of [Budget]
  /// parsed from the response envelope's `data` field.
  Future<List<Budget>> getAll() async {
    final response = await _apiClient.get('/api/budgets');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Budget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new budget entry.
  ///
  /// Sends a POST request to `/api/budgets` with [category], [plannedAmount],
  /// and [actualAmount]. Returns the created [Budget] from the response.
  Future<Budget> create({
    required String category,
    required double plannedAmount,
    required double actualAmount,
  }) async {
    final response = await _apiClient.post(
      '/api/budgets',
      data: {
        'category': category,
        'planned_amount': plannedAmount,
        'actual_amount': actualAmount,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Budget.fromJson(data);
  }

  /// Updates an existing budget entry.
  ///
  /// Sends a PUT request to `/api/budgets/{id}` with the updated
  /// [category], [plannedAmount], and [actualAmount].
  /// Returns the updated [Budget] from the response.
  Future<Budget> update({
    required int id,
    required String category,
    required double plannedAmount,
    required double actualAmount,
  }) async {
    final response = await _apiClient.put(
      '/api/budgets/$id',
      data: {
        'category': category,
        'planned_amount': plannedAmount,
        'actual_amount': actualAmount,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Budget.fromJson(data);
  }

  /// Deletes a budget entry by [id].
  ///
  /// Sends a DELETE request to `/api/budgets/{id}`.
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/budgets/$id');
  }
}
