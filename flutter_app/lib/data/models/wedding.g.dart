// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wedding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wedding _$WeddingFromJson(Map<String, dynamic> json) => Wedding(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      groomName: json['groom_name'] as String,
      brideName: json['bride_name'] as String,
      weddingDate: json['wedding_date'] == null
          ? null
          : DateTime.parse(json['wedding_date'] as String),
      location: json['location'] as String?,
      totalBudget: (json['total_budget'] as num).toDouble(),
      themeColor: json['theme_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
    );

Map<String, dynamic> _$WeddingToJson(Wedding instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'groom_name': instance.groomName,
      'bride_name': instance.brideName,
      'wedding_date': instance.weddingDate?.toIso8601String(),
      'location': instance.location,
      'total_budget': instance.totalBudget,
      'theme_color': instance.themeColor,
      'secondary_color': instance.secondaryColor,
    };
