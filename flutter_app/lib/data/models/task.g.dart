// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: (json['id'] as num).toInt(),
      weddingId: (json['wedding_id'] as num).toInt(),
      phaseId: (json['phase_id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      notes: json['notes'] as String?,
      isCompleted: json['is_completed'] as bool,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      sortOrder: (json['sort_order'] as num).toInt(),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'wedding_id': instance.weddingId,
      'phase_id': instance.phaseId,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'category': instance.category,
      'priority': instance.priority,
      'due_date': instance.dueDate?.toIso8601String(),
      'notes': instance.notes,
      'is_completed': instance.isCompleted,
      'completed_at': instance.completedAt?.toIso8601String(),
      'sort_order': instance.sortOrder,
    };
