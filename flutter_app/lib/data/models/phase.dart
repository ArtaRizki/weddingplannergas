import 'package:json_annotation/json_annotation.dart';

part 'phase.g.dart';

@JsonSerializable()
class Phase {
  final int id;
  @JsonKey(name: 'wedding_id')
  final int weddingId;
  final String name;
  final String? icon;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'completed_tasks')
  final int completedTasks;
  @JsonKey(name: 'total_tasks')
  final int totalTasks;

  const Phase({
    required this.id,
    required this.weddingId,
    required this.name,
    this.icon,
    this.startDate,
    this.endDate,
    required this.sortOrder,
    required this.completedTasks,
    required this.totalTasks,
  });

  /// Computed progress percentage
  double get progress =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  factory Phase.fromJson(Map<String, dynamic> json) => _$PhaseFromJson(json);

  Map<String, dynamic> toJson() => _$PhaseToJson(this);
}
