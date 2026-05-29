import 'package:equatable/equatable.dart';

/// Events for the [TaskBloc].
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all tasks from the API.
class LoadTasks extends TaskEvent {
  const LoadTasks();
}

/// Triggered to add a new task.
class AddTask extends TaskEvent {
  final int phaseId;
  final String title;
  final String type;
  final String category;
  final String priority;
  final String? description;
  final DateTime? dueDate;
  final String? notes;

  const AddTask({
    required this.phaseId,
    required this.title,
    required this.type,
    required this.category,
    required this.priority,
    this.description,
    this.dueDate,
    this.notes,
  });

  @override
  List<Object?> get props => [
        phaseId,
        title,
        type,
        category,
        priority,
        description,
        dueDate,
        notes,
      ];
}

/// Triggered to toggle a task's completion status.
class ToggleTask extends TaskEvent {
  final int taskId;

  const ToggleTask({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Triggered to delete a task.
class DeleteTask extends TaskEvent {
  final int taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Triggered to filter tasks by phase.
/// If [phaseId] is null, all tasks are shown (no filter).
class FilterByPhase extends TaskEvent {
  final int? phaseId;

  const FilterByPhase({this.phaseId});

  @override
  List<Object?> get props => [phaseId];
}
