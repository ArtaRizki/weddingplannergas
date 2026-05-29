import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget {
  final int id;
  @JsonKey(name: 'wedding_id')
  final int weddingId;
  final String category;
  @JsonKey(name: 'planned_amount')
  final double plannedAmount;
  @JsonKey(name: 'actual_amount')
  final double actualAmount;

  const Budget({
    required this.id,
    required this.weddingId,
    required this.category,
    required this.plannedAmount,
    required this.actualAmount,
  });

  /// Computed: planned - actual
  double get remaining => plannedAmount - actualAmount;

  /// Computed: (actual / planned) * 100, returns 0 if planned is 0
  double get percentage =>
      plannedAmount > 0 ? (actualAmount / plannedAmount) * 100 : 0;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
