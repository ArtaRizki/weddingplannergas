import 'package:equatable/equatable.dart';

import '../../../data/models/budget.dart';

/// States for the [BudgetBloc].
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any budget data has been requested.
class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

/// Budget data is currently being loaded from the API.
class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

/// Budget data has been successfully loaded.
///
/// Contains the list of budgets along with computed summary totals.
class BudgetLoaded extends BudgetState {
  /// The list of all budget entries.
  final List<Budget> budgets;

  /// Sum of all planned amounts.
  double get totalPlanned =>
      budgets.fold(0.0, (sum, b) => sum + b.plannedAmount);

  /// Sum of all actual amounts.
  double get totalActual =>
      budgets.fold(0.0, (sum, b) => sum + b.actualAmount);

  const BudgetLoaded({required this.budgets});

  @override
  List<Object?> get props => [budgets];
}

/// An error occurred during a budget operation.
///
/// If [budgets] is non-null, it contains the last successfully loaded
/// budget list that should still be displayed to the user (requirement 4.7).
class BudgetError extends BudgetState {
  /// A user-friendly error message describing what went wrong.
  final String message;

  /// Previously loaded budget data to preserve on screen during errors.
  /// Null if no data was previously loaded (e.g., initial load failure).
  final List<Budget>? budgets;

  const BudgetError({
    required this.message,
    this.budgets,
  });

  @override
  List<Object?> get props => [message, budgets];
}
