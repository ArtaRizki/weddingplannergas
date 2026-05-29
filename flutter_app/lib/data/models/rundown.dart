import 'package:json_annotation/json_annotation.dart';

part 'rundown.g.dart';

@JsonSerializable()
class Rundown {
  final int id;
  @JsonKey(name: 'wedding_id')
  final int weddingId;
  final String name;
  final String time;
  final String? location;
  final String? pic;
  final String? notes;

  const Rundown({
    required this.id,
    required this.weddingId,
    required this.name,
    required this.time,
    this.location,
    this.pic,
    this.notes,
  });

  factory Rundown.fromJson(Map<String, dynamic> json) =>
      _$RundownFromJson(json);

  Map<String, dynamic> toJson() => _$RundownToJson(this);
}
