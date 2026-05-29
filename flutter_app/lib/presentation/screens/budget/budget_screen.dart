import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/budget.dart';
import '../../../domain/blocs/budget/budget_bloc.dart';
import 'budget_form_screen.dart';

/// Budget list screen displaying all budget categories with summary totals.
///
/// Shows planned amount, actual amount, remaining (planned - actual),
/// and percentage spent per item. Includes summary totals at the top.
/// Requirements: 4.1, 4.2, 4.5, 4.7
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(const LoadBudgets());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<BudgetBloc>();
    bloc.add(const LoadBudgets());
    await bloc.stream.firstWhere((state) => state is! BudgetLoading);
  }

  void _navigateToAddForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BudgetBloc>(),
          child: const BudgetFormScreen(),
        ),
      ),
    );
  }

  void _navigateToEditForm(Budget budget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BudgetBloc>(),
          child: BudgetFormScreen(budget: budget),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Budget budget) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
        ),
        title: const Text('Hapus Budget', style: AppTypography.h4),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${budget.category}"?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Batal', style: AppTypography.body.copyWith(color: AppTheme.darkGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BudgetBloc>().add(DeleteBudget(id: budget.id));
            },
            child: Text('Hapus', style: AppTypography.body.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Budget', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          final budgets = _getBudgets(state);
          if (budgets == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppTheme.pink,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(budgets),
                  const SizedBox(height: 16),
                  if (budgets.isEmpty)
                    _buildNoBudgetsMessage()
                  else
                    ...budgets.map((budget) => _buildBudgetItem(budget)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  List<Budget>? _getBudgets(BudgetState state) {
    if (state is BudgetLoaded) return state.budgets;
    if (state is BudgetError) return state.budgets;
    return null;
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppTheme.lightPink),
          SizedBox(height: 16),
          Text('Tidak dapat memuat data budget.', style: AppTypography.body),
          SizedBox(height: 8),
          Text('Tarik ke bawah untuk refresh.', style: AppTypography.secondary),
        ],
      ),
    );
  }

  /// Summary card showing total planned and total actual.
  /// Requirement 4.2
  Widget _buildSummaryCard(List<Budget> budgets) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final totalPlanned = budgets.fold(0.0, (sum, b) => sum + b.plannedAmount);
    final totalActual = budgets.fold(0.0, (sum, b) => sum + b.actualAmount);

    return NeoCard(
      backgroundColor: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Budget', style: AppTypography.h4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: 'Total Rencana',
                  value: currencyFormat.format(totalPlanned),
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Total Aktual',
                  value: currencyFormat.format(totalActual),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightPink,
        border: Border.all(color: AppTheme.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.pink),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: AppTypography.caption)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNoBudgetsMessage() {
    return const NeoCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Belum ada data budget.\nTap + untuk menambahkan.',
            textAlign: TextAlign.center,
            style: AppTypography.secondary,
          ),
        ),
      ),
    );
  }

  /// Individual budget item card showing planned, actual, remaining, percentage.
  /// Requirement 4.1
  Widget _buildBudgetItem(Budget budget) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final percentage = budget.percentage;
    final isOverBudget = budget.actualAmount > budget.plannedAmount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    budget.category,
                    style: AppTypography.h4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _navigateToEditForm(budget),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.edit, size: 20, color: AppTheme.darkGray),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _showDeleteConfirmation(budget),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete, size: 20, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBudgetRow('Rencana', currencyFormat.format(budget.plannedAmount)),
            const SizedBox(height: 4),
            _buildBudgetRow('Aktual', currencyFormat.format(budget.actualAmount)),
            const SizedBox(height: 4),
            _buildBudgetRow(
              'Sisa',
              currencyFormat.format(budget.remaining),
              valueColor: isOverBudget ? Colors.red : AppTheme.black,
            ),
            const SizedBox(height: 4),
            _buildBudgetRow(
              'Persentase',
              '${percentage.toStringAsFixed(1)}%',
              valueColor: isOverBudget ? Colors.red : AppTheme.pink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.secondary),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.black,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return NeoButton(
      onPressed: _navigateToAddForm,
      label: '+',
      padding: const EdgeInsets.all(16),
    );
  }
}
