// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    DashboardData(
      wedding: Wedding.fromJson(json['wedding'] as Map<String, dynamic>),
      overallProgress: (json['overall_progress'] as num).toDouble(),
      totalTasks: (json['total_tasks'] as num).toInt(),
      completedTasks: (json['completed_tasks'] as num).toInt(),
      totalBudget: (json['total_budget'] as num).toDouble(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      totalGuests: (json['total_guests'] as num).toInt(),
      confirmedGuests: (json['confirmed_guests'] as num).toInt(),
      upcomingActions: (json['upcoming_actions'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingInputs: (json['pending_inputs'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardDataToJson(DashboardData instance) =>
    <String, dynamic>{
      'wedding': instance.wedding,
      'overall_progress': instance.overallProgress,
      'total_tasks': instance.totalTasks,
      'completed_tasks': instance.completedTasks,
      'total_budget': instance.totalBudget,
      'total_spent': instance.totalSpent,
      'total_guests': instance.totalGuests,
      'confirmed_guests': instance.confirmedGuests,
      'upcoming_actions': instance.upcomingActions,
      'pending_inputs': instance.pendingInputs,
    };
