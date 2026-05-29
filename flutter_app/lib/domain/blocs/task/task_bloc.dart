import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/task.dart';
import '../../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

export 'task_event.dart';
export 'task_state.dart';

/// BLoC managing task operations: load, add, toggle, delete, and filter.
///
/// Implements optimistic update for toggle (reverts on failure) and
/// retains previous state on error (requirement 7.6).
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc({
    required TaskRepository taskRepository,
  })  : _taskRepository = taskRepository,
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
    on<FilterByPhase>(_onFilterByPhase);
  }

  /// Handles the [LoadTasks] event.
  ///
  /// Emits [TaskLoading], then fetches all tasks from the API.
  /// On success, emits [TaskLoaded]. On failure, emits [TaskError]
  /// with previously loaded data retained.
  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    final previousTasks = _getPreviousTasks();
    final previousFilter = _getPreviousFilter();

    emit(const TaskLoading());

    try {
      final tasks = await _taskRepository.getAll();
      emit(TaskLoaded(tasks: tasks, filterPhaseId: previousFilter));
    } catch (e) {
      emit(TaskError(
        message: _extractErrorMessage(e),
        previousTasks: previousTasks,
        filterPhaseId: previousFilter,
      ));
    }
  }

  /// Handles the [AddTask] event.
  ///
  /// Creates a new task via the API and appends it to the current list.
  /// On failure, emits [TaskError] retaining the previous task list.
  Future<void> _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    final previousTasks = _getPreviousTasks();
    final previousFilter = _getPreviousFilter();

    try {
      final newTask = await _taskRepository.create(
        phaseId: event.phaseId,
        title: event.title,
        type: event.type,
        category: event.category,
        priority: event.priority,
        description: event.description,
        dueDate: event.dueDate,
        notes: event.notes,
      );

      final updatedTasks = [...?previousTasks, newTask];
      emit(TaskLoaded(tasks: updatedTasks, filterPhaseId: previousFilter));
    } catch (e) {
      emit(TaskError(
        message: _extractErrorMessage(e),
        previousTasks: previousTasks,
        filterPhaseId: previousFilter,
      ));
    }
  }

  /// Handles the [ToggleTask] event with optimistic update.
  ///
  /// Immediately updates the UI with the toggled state, then sends
  /// the PATCH request. If the request fails, reverts to the previous
  /// state and emits an error.
  Future<void> _onToggleTask(
    ToggleTask event,
    Emitter<TaskState> emit,
  ) async {
    final previousTasks = _getPreviousTasks();
    final previousFilter = _getPreviousFilter();

    if (previousTasks == null) return;

    // Optimistic update: toggle the task locally
    final optimisticTasks = previousTasks.map((task) {
      if (task.id == event.taskId) {
        return Task(
          id: task.id,
          weddingId: task.weddingId,
          phaseId: task.phaseId,
          title: task.title,
          description: task.description,
          type: task.type,
          category: task.category,
          priority: task.priority,
          dueDate: task.dueDate,
          notes: task.notes,
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? DateTime.now() : null,
          sortOrder: task.sortOrder,
        );
      }
      return task;
    }).toList();

    emit(TaskLoaded(tasks: optimisticTasks, filterPhaseId: previousFilter));

    try {
      // Send the actual API request
      final updatedTask = await _taskRepository.toggleComplete(event.taskId);

      // Replace with the server response
      final confirmedTasks = optimisticTasks.map((task) {
        if (task.id == event.taskId) {
          return updatedTask;
        }
        return task;
      }).toList();

      emit(TaskLoaded(tasks: confirmedTasks, filterPhaseId: previousFilter));
    } catch (e) {
      // Revert to previous state on failure
      emit(TaskLoaded(tasks: previousTasks, filterPhaseId: previousFilter));
      emit(TaskError(
        message: _extractErrorMessage(e),
        previousTasks: previousTasks,
        filterPhaseId: previousFilter,
      ));
    }
  }

  /// Handles the [DeleteTask] event.
  ///
  /// Sends a DELETE request to the API. On success, removes the task
  /// from the list. On failure, retains the previous state.
  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    final previousTasks = _getPreviousTasks();
    final previousFilter = _getPreviousFilter();

    if (previousTasks == null) return;

    try {
      await _taskRepository.delete(event.taskId);

      final updatedTasks =
          previousTasks.where((task) => task.id != event.taskId).toList();
      emit(TaskLoaded(tasks: updatedTasks, filterPhaseId: previousFilter));
    } catch (e) {
      emit(TaskError(
        message: _extractErrorMessage(e),
        previousTasks: previousTasks,
        filterPhaseId: previousFilter,
      ));
    }
  }

  /// Handles the [FilterByPhase] event.
  ///
  /// Updates the active phase filter without re-fetching data.
  /// Filtering is done client-side on the already loaded tasks.
  void _onFilterByPhase(
    FilterByPhase event,
    Emitter<TaskState> emit,
  ) {
    final previousTasks = _getPreviousTasks();

    if (previousTasks != null) {
      emit(TaskLoaded(tasks: previousTasks, filterPhaseId: event.phaseId));
    }
  }

  /// Extracts previously loaded tasks from the current state.
  List<Task>? _getPreviousTasks() {
    final currentState = state;
    if (currentState is TaskLoaded) {
      return currentState.tasks;
    }
    if (currentState is TaskError) {
      return currentState.previousTasks;
    }
    return null;
  }

  /// Extracts the previous phase filter from the current state.
  int? _getPreviousFilter() {
    final currentState = state;
    if (currentState is TaskLoaded) {
      return currentState.filterPhaseId;
    }
    if (currentState is TaskError) {
      return currentState.filterPhaseId;
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
    return 'Failed to perform task operation. Please try again.';
  }
}
