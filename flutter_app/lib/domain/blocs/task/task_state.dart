import 'package:equatable/equatable.dart';

import '../../../data/models/task.dart';

/// States for the [TaskBloc].
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any task data has been requested.
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Tasks are currently being loaded from the API.
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Tasks have been successfully loaded.
class TaskLoaded extends TaskState {
  /// All tasks retrieved from the API.
  final List<Task> tasks;

  /// The currently active phase filter. Null means no filter (show all).
  final int? filterPhaseId;

  const TaskLoaded({
    required this.tasks,
    this.filterPhaseId,
  });

  /// Returns tasks filtered by the active phase filter and ordered by due date.
  List<Task> get filteredTasks {
    var result = filterPhaseId != null
        ? tasks.where((t) => t.phaseId == filterPhaseId).toList()
        : List<Task>.from(tasks);

    result.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return result;
  }

  @override
  List<Object?> get props => [tasks, filterPhaseId];
}

/// An error occurred while performing a task operation.
///
/// If [previousTasks] is non-null, it contains the last successfully
/// loaded tasks that should still be displayed (requirement 7.6).
class TaskError extends TaskState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  /// Previously loaded tasks to retain on screen during errors.
  final List<Task>? previousTasks;

  /// The phase filter that was active before the error.
  final int? filterPhaseId;

  const TaskError({
    required this.message,
    this.previousTasks,
    this.filterPhaseId,
  });

  @override
  List<Object?> get props => [message, previousTasks, filterPhaseId];
}
