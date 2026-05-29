// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
      id: (json['id'] as num).toInt(),
      weddingId: (json['wedding_id'] as num).toInt(),
      category: json['category'] as String,
      plannedAmount: (json['planned_amount'] as num).toDouble(),
      actualAmount: (json['actual_amount'] as num).toDouble(),
    );

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
      'id': instance.id,
      'wedding_id': instance.weddingId,
      'category': instance.category,
      'planned_amount': instance.plannedAmount,
      'actual_amount': instance.actualAmount,
    };
