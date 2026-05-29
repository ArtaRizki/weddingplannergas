import '../api/api_client.dart';
import '../models/phase.dart';
import '../models/task.dart';

/// Repository handling phase data operations with the Laravel API.
///
/// Provides methods for listing phases and fetching phase details.
class PhaseRepository {
  final ApiClient _apiClient;

  PhaseRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches all phases from the API.
  ///
  /// Sends a GET request to `/api/phases` and returns a list of [Phase]
  /// parsed from the response envelope's `data` field.
  ///
  /// The API returns `order` instead of `sort_order` and may omit `wedding_id`,
  /// so this method normalizes the JSON before parsing.
  Future<List<Phase>> getAll() async {
    final response = await _apiClient.get('/api/phases');
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) {
      final phaseMap = Map<String, dynamic>.from(json as Map<String, dynamic>);
      // Normalize API response keys to match Phase model expectations
      phaseMap['sort_order'] = phaseMap['sort_order'] ?? phaseMap['order'] ?? 0;
      phaseMap['wedding_id'] = phaseMap['wedding_id'] ?? 0;
      return Phase.fromJson(phaseMap);
    }).toList();
  }

  /// Fetches a single phase with its tasks by ID.
  ///
  /// Sends a GET request to `/api/phases/{id}` and returns a [PhaseDetail]
  /// containing the phase information and its associated tasks ordered by sort order.
  ///
  /// The API returns task fields with slightly different keys than the Task model
  /// expects (e.g., `completed` vs `is_completed`, `order` vs `sort_order`),
  /// so this method normalizes the JSON before parsing.
  Future<PhaseDetail> getDetail(int id) async {
    final response = await _apiClient.get('/api/phases/$id');
    final data = response.data['data'] as Map<String, dynamic>;

    final phase = Phase.fromJson({
      ...data,
      'sort_order': data['sort_order'] ?? data['order'] ?? 0,
      'wedding_id': data['wedding_id'] ?? 0,
    });

    final tasksJson = data['tasks'] as List<dynamic>? ?? [];
    final tasks = tasksJson.map((json) {
      final taskMap = Map<String, dynamic>.from(json as Map<String, dynamic>);
      // Normalize API response keys to match Task model expectations
      taskMap['wedding_id'] = taskMap['wedding_id'] ?? phase.weddingId;
      taskMap['phase_id'] = taskMap['phase_id'] ?? id;
      taskMap['is_completed'] = taskMap['is_completed'] ?? taskMap['completed'] ?? false;
      taskMap['sort_order'] = taskMap['sort_order'] ?? taskMap['order'] ?? 0;
      return Task.fromJson(taskMap);
    }).toList();

    return PhaseDetail(phase: phase, tasks: tasks);
  }
}

/// Holds a phase along with its associated tasks.
///
/// Returned by [PhaseRepository.getDetail] to provide both the phase
/// metadata and the list of tasks belonging to that phase.
class PhaseDetail {
  final Phase phase;
  final List<Task> tasks;

  const PhaseDetail({
    required this.phase,
    required this.tasks,
  });
}
