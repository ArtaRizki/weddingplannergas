import 'package:equatable/equatable.dart';

/// Events for the [BudgetBloc].
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all budget entries from the API.
class LoadBudgets extends BudgetEvent {
  const LoadBudgets();
}

/// Triggered to add a new budget entry.
class AddBudget extends BudgetEvent {
  final String category;
  final double plannedAmount;
  final double actualAmount;

  const AddBudget({
    required this.category,
    required this.plannedAmount,
    required this.actualAmount,
  });

  @override
  List<Object?> get props => [category, plannedAmount, actualAmount];
}

/// Triggered to update an existing budget entry.
class UpdateBudget extends BudgetEvent {
  final int id;
  final String category;
  final double plannedAmount;
  final double actualAmount;

  const UpdateBudget({
    required this.id,
    required this.category,
    required this.plannedAmount,
    required this.actualAmount,
  });

  @override
  List<Object?> get props => [id, category, plannedAmount, actualAmount];
}

/// Triggered to delete a budget entry by ID.
class DeleteBudget extends BudgetEvent {
  final int id;

  const DeleteBudget({required this.id});

  @override
  List<Object?> get props => [id];
}
