import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final int id;
  @JsonKey(name: 'wedding_id')
  final int weddingId;
  @JsonKey(name: 'phase_id')
  final int phaseId;
  final String title;
  final String? description;
  final String type;
  final String category;
  final String priority;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  final String? notes;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  const Task({
    required this.id,
    required this.weddingId,
    required this.phaseId,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.priority,
    this.dueDate,
    this.notes,
    required this.isCompleted,
    this.completedAt,
    required this.sortOrder,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
