// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phase _$PhaseFromJson(Map<String, dynamic> json) => Phase(
      id: (json['id'] as num).toInt(),
      weddingId: (json['wedding_id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      sortOrder: (json['sort_order'] as num).toInt(),
      completedTasks: (json['completed_tasks'] as num).toInt(),
      totalTasks: (json['total_tasks'] as num).toInt(),
    );

Map<String, dynamic> _$PhaseToJson(Phase instance) => <String, dynamic>{
      'id': instance.id,
      'wedding_id': instance.weddingId,
      'name': instance.name,
      'icon': instance.icon,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'sort_order': instance.sortOrder,
      'completed_tasks': instance.completedTasks,
      'total_tasks': instance.totalTasks,
    };
