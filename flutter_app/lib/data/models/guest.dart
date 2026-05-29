import 'package:json_annotation/json_annotation.dart';

part 'guest.g.dart';

enum GuestSide {
  @JsonValue('Pria')
  pria,
  @JsonValue('Wanita')
  wanita,
  @JsonValue('Keluarga')
  keluarga,
}

enum GuestStatus {
  @JsonValue('Belum Diundang')
  belumDiundang,
  @JsonValue('Diundang')
  diundang,
  @JsonValue('Konfirmasi')
  konfirmasi,
  @JsonValue('Hadir')
  hadir,
}

@JsonSerializable()
class Guest {
  final int id;
  @JsonKey(name: 'wedding_id')
  final int weddingId;
  final String name;
  final GuestSide side;
  final String? phone;
  final String? email;
  final GuestStatus status;

  const Guest({
    required this.id,
    required this.weddingId,
    required this.name,
    required this.side,
    this.phone,
    this.email,
    required this.status,
  });

  factory Guest.fromJson(Map<String, dynamic> json) => _$GuestFromJson(json);

  Map<String, dynamic> toJson() => _$GuestToJson(this);
}
