import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/budget.dart';
import '../../../data/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

export 'budget_event.dart';
export 'budget_state.dart';

/// BLoC managing budget CRUD operations and state.
///
/// Handles [LoadBudgets], [AddBudget], [UpdateBudget], and [DeleteBudget]
/// events. On operation failure, preserves the user's current data on screen
/// (requirement 4.7).
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;

  BudgetBloc({
    required BudgetRepository budgetRepository,
  })  : _budgetRepository = budgetRepository,
        super(const BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudget>(_onAddBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
  }

  /// Handles the [LoadBudgets] event.
  ///
  /// Emits [BudgetLoading], then fetches all budgets from the API.
  /// On success, emits [BudgetLoaded]. On failure, emits [BudgetError]
  /// with any previously loaded data preserved.
  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    final List<Budget>? previousBudgets = _getPreviousBudgets();

    emit(const BudgetLoading());

    try {
      final budgets = await _budgetRepository.getAll();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(
        message: _extractErrorMessage(e),
        budgets: previousBudgets,
      ));
    }
  }

  /// Handles the [AddBudget] event.
  ///
  /// Sends a create request to the API. On success, reloads the full
  /// budget list. On failure, emits [BudgetError] preserving current data.
  Future<void> _onAddBudget(
    AddBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final List<Budget>? previousBudgets = _getPreviousBudgets();

    emit(const BudgetLoading());

    try {
      await _budgetRepository.create(
        category: event.category,
        plannedAmount: event.plannedAmount,
        actualAmount: event.actualAmount,
      );
      final budgets = await _budgetRepository.getAll();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(
        message: _extractErrorMessage(e),
        budgets: previousBudgets,
      ));
    }
  }

  /// Handles the [UpdateBudget] event.
  ///
  /// Sends an update request to the API. On success, reloads the full
  /// budget list. On failure, emits [BudgetError] preserving current data.
  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final List<Budget>? previousBudgets = _getPreviousBudgets();

    emit(const BudgetLoading());

    try {
      await _budgetRepository.update(
        id: event.id,
        category: event.category,
        plannedAmount: event.plannedAmount,
        actualAmount: event.actualAmount,
      );
      final budgets = await _budgetRepository.getAll();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(
        message: _extractErrorMessage(e),
        budgets: previousBudgets,
      ));
    }
  }

  /// Handles the [DeleteBudget] event.
  ///
  /// Sends a delete request to the API. On success, reloads the full
  /// budget list. On failure, emits [BudgetError] preserving current data.
  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final List<Budget>? previousBudgets = _getPreviousBudgets();

    emit(const BudgetLoading());

    try {
      await _budgetRepository.delete(event.id);
      final budgets = await _budgetRepository.getAll();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(
        message: _extractErrorMessage(e),
        budgets: previousBudgets,
      ));
    }
  }

  /// Extracts previously loaded budget list from the current state.
  List<Budget>? _getPreviousBudgets() {
    final currentState = state;
    if (currentState is BudgetLoaded) {
      return currentState.budgets;
    }
    if (currentState is BudgetError) {
      return currentState.budgets;
    }
    return null;
  }

  /// Extracts a user-friendly error message from an exception.
  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      final message = error.toString();
      // DioException messages are already user-friendly thanks to ErrorInterceptor
      if (message.contains('Exception: ')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }
    return 'Failed to complete budget operation. Please try again.';
  }
}
