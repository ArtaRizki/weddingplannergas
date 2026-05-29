// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guest _$GuestFromJson(Map<String, dynamic> json) => Guest(
      id: (json['id'] as num).toInt(),
      weddingId: (json['wedding_id'] as num).toInt(),
      name: json['name'] as String,
      side: $enumDecode(_$GuestSideEnumMap, json['side']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: $enumDecode(_$GuestStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$GuestToJson(Guest instance) => <String, dynamic>{
      'id': instance.id,
      'wedding_id': instance.weddingId,
      'name': instance.name,
      'side': _$GuestSideEnumMap[instance.side]!,
      'phone': instance.phone,
      'email': instance.email,
      'status': _$GuestStatusEnumMap[instance.status]!,
    };

const _$GuestSideEnumMap = {
  GuestSide.pria: 'Pria',
  GuestSide.wanita: 'Wanita',
  GuestSide.keluarga: 'Keluarga',
};

const _$GuestStatusEnumMap = {
  GuestStatus.belumDiundang: 'Belum Diundang',
  GuestStatus.diundang: 'Diundang',
  GuestStatus.konfirmasi: 'Konfirmasi',
  GuestStatus.hadir: 'Hadir',
};
