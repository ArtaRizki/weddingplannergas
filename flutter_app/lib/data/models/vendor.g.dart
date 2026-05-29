// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
      id: (json['id'] as num).toInt(),
      weddingId: (json['wedding_id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      cost: (json['cost'] as num).toDouble(),
      status: json['status'] as String? ?? 'Aktif',
    );

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
      'id': instance.id,
      'wedding_id': instance.weddingId,
      'name': instance.name,
      'category': instance.category,
      'phone': instance.phone,
      'email': instance.email,
      'cost': instance.cost,
      'status': instance.status,
    };
