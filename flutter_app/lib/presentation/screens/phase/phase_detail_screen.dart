import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/phase.dart';
import '../../../data/models/task.dart';
import '../../../domain/blocs/phase/phase_bloc.dart';

/// Phase detail screen showing all tasks belonging to a selected phase.
///
/// Tasks are ordered by sort order and display title, priority,
/// due date, and completed status.
/// Requirements: 6.2
class PhaseDetailScreen extends StatefulWidget {
  const PhaseDetailScreen({
    super.key,
    required this.phase,
  });

  final Phase phase;

  @override
  State<PhaseDetailScreen> createState() => _PhaseDetailScreenState();
}

class _PhaseDetailScreenState extends State<PhaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PhaseBloc>().add(LoadPhaseDetail(phaseId: widget.phase.id));
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<PhaseBloc>();
    bloc.add(LoadPhaseDetail(phaseId: widget.phase.id));
    await bloc.stream.firstWhere((state) => state is! PhaseLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(widget.phase.name, style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<PhaseBloc, PhaseState>(
        listener: (context, state) {
          if (state is PhaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PhaseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          if (state is PhaseDetailLoaded) {
            return _buildDetailContent(state.phase, state.tasks);
          }

          if (state is PhaseError) {
            return _buildErrorState();
          }

          return const Center(
            child: CircularProgressIndicator(color: AppTheme.pink),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(Phase phase, List<Task> tasks) {
    return RefreshIndicator(
      color: AppTheme.pink,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhaseHeader(phase),
            const SizedBox(height: 16),
            Text(
              'Tasks (${phase.completedTasks}/${phase.totalTasks})',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              _buildNoTasksMessage()
            else
              ...tasks.map((task) => _buildTaskItem(task)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseHeader(Phase phase) {
    final progressPercent = phase.progress;

    return NeoCard(
      backgroundColor: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (phase.icon != null && phase.icon!.isNotEmpty) ...[
                Text(phase.icon!, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phase.name, style: AppTypography.h3),
                    if (_hasDateRange(phase)) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDateRange(phase),
                        style: AppTypography.secondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progressPercent.toStringAsFixed(1)}% complete',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${phase.completedTasks}/${phase.totalTasks} tasks',
                style: AppTypography.secondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(progressPercent),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percentage) {
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.black, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clampedPercentage / 100,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.pink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final isCompleted = task.isCompleted;
    final isOverdue = !isCompleted &&
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildCompletionIndicator(isCompleted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: isCompleted
                        ? AppTypography.body.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.darkGray,
                          )
                        : AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildPriorityBadge(task.priority),
                      if (task.dueDate != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: isOverdue ? Colors.red : AppTheme.darkGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d').format(task.dueDate!),
                          style: AppTypography.secondary.copyWith(
                            color: isOverdue ? Colors.red : AppTheme.darkGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionIndicator(bool isCompleted) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.pink : AppTheme.white,
        border: Border.all(color: AppTheme.black, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 16, color: AppTheme.white)
          : null,
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color badgeColor;
    switch (priority.toLowerCase()) {
      case 'tinggi':
        badgeColor = Colors.red.shade400;
        break;
      case 'sedang':
        badgeColor = Colors.orange.shade400;
        break;
      case 'rendah':
      default:
        badgeColor = Colors.green.shade400;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        border: Border.all(color: badgeColor, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildNoTasksMessage() {
    return const NeoCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Belum ada task untuk fase ini.',
            textAlign: TextAlign.center,
            style: AppTypography.secondary,
          ),
        ),
      ),
    );
  }

  /// Checks if the phase has at least one date to display.
  bool _hasDateRange(Phase phase) {
    return phase.startDate != null || phase.endDate != null;
  }

  /// Formats the date range for display.
  ///
  /// - Both dates: "Jan 10 - Dec 15"
  /// - Only start date: "Starts: Jan 10"
  /// - Only end date: "Ends: Dec 15"
  String _formatDateRange(Phase phase) {
    final dateFormat = DateFormat('MMM d');

    if (phase.startDate != null && phase.endDate != null) {
      return '${dateFormat.format(phase.startDate!)} - ${dateFormat.format(phase.endDate!)}';
    } else if (phase.startDate != null) {
      return 'Starts: ${dateFormat.format(phase.startDate!)}';
    } else if (phase.endDate != null) {
      return 'Ends: ${dateFormat.format(phase.endDate!)}';
    }
    return '';
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.lightPink),
          const SizedBox(height: 16),
          const Text('Tidak dapat memuat detail fase.', style: AppTypography.body),
          const SizedBox(height: 8),
          const Text('Tarik ke bawah untuk refresh.', style: AppTypography.secondary),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.read<PhaseBloc>().add(
                  LoadPhaseDetail(phaseId: widget.phase.id),
                ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.pink,
                border: Border.all(color: AppTheme.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Coba Lagi', style: AppTypography.button),
            ),
          ),
        ],
      ),
    );
  }
}
