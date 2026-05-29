// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rundown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rundown _$RundownFromJson(Map<String, dynamic> json) => Rundown(
      id: (json['id'] as num).toInt(),
      weddingId: (json['wedding_id'] as num).toInt(),
      name: json['name'] as String,
      time: json['time'] as String,
      location: json['location'] as String?,
      pic: json['pic'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$RundownToJson(Rundown instance) => <String, dynamic>{
      'id': instance.id,
      'wedding_id': instance.weddingId,
      'name': instance.name,
      'time': instance.time,
      'location': instance.location,
      'pic': instance.pic,
      'notes': instance.notes,
    };
