import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/dashboard_data.dart';
import '../../../data/models/task.dart';
import '../../../domain/blocs/dashboard/dashboard_bloc.dart';

/// Dashboard screen displaying wedding planning overview.
///
/// Shows groom/bride names, wedding date, task progress, budget summary,
/// guest counts, and upcoming tasks. Supports pull-to-refresh.
/// Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<DashboardBloc>();
    bloc.add(const LoadDashboard());
    // Wait for the bloc to emit a non-loading state
    await bloc.stream.firstWhere(
      (state) => state is! DashboardLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Dashboard', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading && _getPreviousData(state) == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          final data = _getDisplayData(state);
          if (data == null) {
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
                  _buildWeddingHeader(data),
                  const SizedBox(height: 16),
                  _buildProgressCard(data),
                  const SizedBox(height: 16),
                  _buildBudgetCard(data),
                  const SizedBox(height: 16),
                  _buildGuestCard(data),
                  const SizedBox(height: 16),
                  if (data.upcomingActions.isNotEmpty)
                    _buildTaskSection(
                      title: 'Upcoming Tasks',
                      icon: Icons.play_circle_outline,
                      tasks: data.upcomingActions,
                    ),
                  if (data.pendingInputs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildTaskSection(
                      title: 'Pending Input',
                      icon: Icons.edit_note,
                      tasks: data.pendingInputs,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Extracts displayable data from the current state.
  DashboardData? _getDisplayData(DashboardState state) {
    if (state is DashboardLoaded) return state.data;
    if (state is DashboardError) return state.previousData;
    if (state is DashboardLoading) return _getPreviousData(state);
    return null;
  }

  /// Gets previous data when in loading state (for showing stale data during refresh).
  DashboardData? _getPreviousData(DashboardState state) {
    // The bloc retains previous data in error state, but during loading
    // we rely on the previous state being available via the bloc's internal logic.
    // For the UI, we check if the bloc had data before.
    final bloc = context.read<DashboardBloc>();
    final currentState = bloc.state;
    if (currentState is DashboardLoaded) return currentState.data;
    if (currentState is DashboardError) return currentState.previousData;
    return null;
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_outlined, size: 64, color: AppTheme.lightPink),
          SizedBox(height: 16),
          Text(
            'Unable to load dashboard data.',
            style: AppTypography.body,
          ),
          SizedBox(height: 8),
          Text(
            'Pull down to refresh.',
            style: AppTypography.secondary,
          ),
        ],
      ),
    );
  }

  /// Wedding header card with groom name, bride name, and wedding date.
  /// Requirement 3.1
  Widget _buildWeddingHeader(DashboardData data) {
    final wedding = data.wedding;
    final dateText = wedding.weddingDate != null
        ? DateFormat('EEEE, d MMMM yyyy').format(wedding.weddingDate!)
        : 'Wedding date not set';

    return NeoCard(
      backgroundColor: AppTheme.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  wedding.groomName,
                  style: AppTypography.h3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('&', style: AppTypography.h3.copyWith(color: AppTheme.pink)),
              ),
              Flexible(
                child: Text(
                  wedding.brideName,
                  style: AppTypography.h3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppTheme.darkGray),
              const SizedBox(width: 6),
              Text(
                dateText,
                style: wedding.weddingDate != null
                    ? AppTypography.body
                    : AppTypography.secondary.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Task completion progress card with percentage and progress bar.
  /// Requirement 3.2
  Widget _buildProgressCard(DashboardData data) {
    final progress = data.totalTasks > 0
        ? (data.completedTasks / data.totalTasks * 100)
        : 0.0;
    final progressFraction = data.totalTasks > 0
        ? data.completedTasks / data.totalTasks
        : 0.0;
    final progressText = '${progress.toStringAsFixed(1)}%';

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Task Progress', style: AppTypography.h4),
              Text(progressText, style: AppTypography.h4.copyWith(color: AppTheme.pink)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.black, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressFraction.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.completedTasks} of ${data.totalTasks} tasks completed',
            style: AppTypography.secondary,
          ),
        ],
      ),
    );
  }

  /// Budget summary card showing total budget and total spent.
  /// Requirement 3.3
  Widget _buildBudgetCard(DashboardData data) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget', style: AppTypography.h4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total Budget',
                  value: currencyFormat.format(data.totalBudget),
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Total Spent',
                  value: currencyFormat.format(data.totalSpent),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Guest count card showing total and confirmed guests.
  /// Requirement 3.4
  Widget _buildGuestCard(DashboardData data) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Guests', style: AppTypography.h4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total Guests',
                  value: data.totalGuests.toString(),
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Confirmed',
                  value: data.confirmedGuests.toString(),
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A stat item widget used in budget and guest cards.
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
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
              Expanded(
                child: Text(label, style: AppTypography.caption),
              ),
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

  /// Task section showing up to 5 tasks sorted by due date.
  /// Requirements 3.5, 3.6
  Widget _buildTaskSection({
    required String title,
    required IconData icon,
    required List<Task> tasks,
  }) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.pink),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.h4),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.take(5).map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  /// Individual task item showing title and due date.
  Widget _buildTaskItem(Task task) {
    final dueDateText = task.dueDate != null
        ? DateFormat('d MMM yyyy').format(task.dueDate!)
        : 'No due date';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: AppTypography.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dueDateText,
              style: AppTypography.secondary.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
