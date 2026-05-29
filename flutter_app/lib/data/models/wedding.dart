import 'package:json_annotation/json_annotation.dart';

part 'wedding.g.dart';

@JsonSerializable()
class Wedding {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'groom_name')
  final String groomName;
  @JsonKey(name: 'bride_name')
  final String brideName;
  @JsonKey(name: 'wedding_date')
  final DateTime? weddingDate;
  final String? location;
  @JsonKey(name: 'total_budget')
  final double totalBudget;
  @JsonKey(name: 'theme_color')
  final String? themeColor;
  @JsonKey(name: 'secondary_color')
  final String? secondaryColor;

  const Wedding({
    required this.id,
    required this.userId,
    required this.groomName,
    required this.brideName,
    this.weddingDate,
    this.location,
    required this.totalBudget,
    this.themeColor,
    this.secondaryColor,
  });

  factory Wedding.fromJson(Map<String, dynamic> json) =>
      _$WeddingFromJson(json);

  Map<String, dynamic> toJson() => _$WeddingToJson(this);
}
