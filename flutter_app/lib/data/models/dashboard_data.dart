import 'package:json_annotation/json_annotation.dart';
import 'package:wedding_planner/data/models/task.dart';
import 'package:wedding_planner/data/models/wedding.dart';

part 'dashboard_data.g.dart';

@JsonSerializable()
class DashboardData {
  final Wedding wedding;
  @JsonKey(name: 'overall_progress')
  final double overallProgress;
  @JsonKey(name: 'total_tasks')
  final int totalTasks;
  @JsonKey(name: 'completed_tasks')
  final int completedTasks;
  @JsonKey(name: 'total_budget')
  final double totalBudget;
  @JsonKey(name: 'total_spent')
  final double totalSpent;
  @JsonKey(name: 'total_guests')
  final int totalGuests;
  @JsonKey(name: 'confirmed_guests')
  final int confirmedGuests;
  @JsonKey(name: 'upcoming_actions')
  final List<Task> upcomingActions;
  @JsonKey(name: 'pending_inputs')
  final List<Task> pendingInputs;

  const DashboardData({
    required this.wedding,
    required this.overallProgress,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalGuests,
    required this.confirmedGuests,
    required this.upcomingActions,
    required this.pendingInputs,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardDataToJson(this);
}
