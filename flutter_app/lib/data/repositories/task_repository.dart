import '../api/api_client.dart';
import '../models/task.dart';

/// Repository handling task CRUD operations with the Laravel API.
///
/// Provides methods for listing, creating, toggling completion,
/// and deleting tasks via RESTful endpoints.
class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches all tasks from the API.
  ///
  /// Sends a GET request to `/api/tasks` and returns a list of [Task]
  /// parsed from the response envelope's `data` field.
  Future<List<Task>> getAll() async {
    final response = await _apiClient.get('/api/tasks');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new task via the API.
  ///
  /// Sends a POST request to `/api/tasks` with the task data.
  /// Returns the created [Task] from the response.
  Future<Task> create({
    required int phaseId,
    required String title,
    required String type,
    required String category,
    required String priority,
    String? description,
    DateTime? dueDate,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'phase_id': phaseId,
      'title': title,
      'type': type,
      'category': category,
      'priority': priority,
    };

    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (dueDate != null) {
      body['due_date'] = dueDate.toIso8601String().split('T').first;
    }
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    final response = await _apiClient.post('/api/tasks', data: body);
    final data = response.data['data'] as Map<String, dynamic>;
    return Task.fromJson(data);
  }

  /// Toggles the completion status of a task.
  ///
  /// Sends a PATCH request to `/api/tasks/{id}/toggle`.
  /// Returns the updated [Task] from the response.
  Future<Task> toggleComplete(int id) async {
    final response = await _apiClient.patch('/api/tasks/$id/toggle');
    final data = response.data['data'] as Map<String, dynamic>;
    return Task.fromJson(data);
  }

  /// Deletes a task by ID.
  ///
  /// Sends a DELETE request to `/api/tasks/{id}`.
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/tasks/$id');
  }
}
