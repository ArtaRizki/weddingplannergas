import 'package:json_annotation/json_annotation.dart';

part 'vendor.g.dart';

@JsonSerializable()
class Vendor {
  final int id;
  @JsonKey(name: 'wedding_id')
  final int weddingId;
  final String name;
  final String category;
  final String? phone;
  final String? email;
  final double cost;
  final String status;

  const Vendor({
    required this.id,
    required this.weddingId,
    required this.name,
    required this.category,
    this.phone,
    this.email,
    required this.cost,
    this.status = 'Aktif',
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);

  Map<String, dynamic> toJson() => _$VendorToJson(this);
}
