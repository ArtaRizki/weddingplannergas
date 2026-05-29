import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/phase.dart';
import '../../../domain/blocs/phase/phase_bloc.dart';
import 'phase_detail_screen.dart';

/// Phase list screen displaying all wedding planning phases sorted by order.
///
/// Shows each phase's name, icon, date range, progress percentage,
/// and task count in "{completed}/{total}" format.
/// Requirements: 6.1, 6.3, 6.4, 6.5
class PhaseScreen extends StatefulWidget {
  const PhaseScreen({super.key});

  @override
  State<PhaseScreen> createState() => _PhaseScreenState();
}

class _PhaseScreenState extends State<PhaseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PhaseBloc>().add(const LoadPhases());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<PhaseBloc>();
    bloc.add(const LoadPhases());
    await bloc.stream.firstWhere((state) => state is! PhaseLoading);
  }

  void _navigateToDetail(Phase phase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PhaseBloc>(),
          child: PhaseDetailScreen(phase: phase),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Phases', style: AppTypography.h3),
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

          if (state is PhasesLoaded) {
            return _buildPhaseList(state.phases);
          }

          if (state is PhaseError) {
            return _buildErrorState();
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildPhaseList(List<Phase> phases) {
    if (phases.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.pink,
      onRefresh: _onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: phases.length,
        itemBuilder: (context, index) => _buildPhaseItem(phases[index]),
      ),
    );
  }

  Widget _buildPhaseItem(Phase phase) {
    final progressPercent = phase.progress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _navigateToDetail(phase),
        child: NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (phase.icon != null && phase.icon!.isNotEmpty) ...[
                    _buildPhaseIcon(phase.icon!),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase.name,
                          style: AppTypography.h4,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${progressPercent.toStringAsFixed(1)}%',
                        style: AppTypography.h4.copyWith(color: AppTheme.pink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${phase.completedTasks}/${phase.totalTasks}',
                        style: AppTypography.secondary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(progressPercent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseIcon(String icon) {
    // Try to parse the icon as an emoji or use a default icon
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.pink.withValues(alpha: 0.2),
        border: Border.all(color: AppTheme.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
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

  /// Checks if the phase has at least one date to display.
  bool _hasDateRange(Phase phase) {
    return phase.startDate != null || phase.endDate != null;
  }

  /// Formats the date range for display.
  ///
  /// - Both dates: "Jan 10 - Dec 15"
  /// - Only start date: "Starts: Jan 10"
  /// - Only end date: "Ends: Dec 15"
  /// - Neither: returns empty (should not be called)
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_outlined, size: 64, color: AppTheme.lightPink),
          SizedBox(height: 16),
          Text('Belum ada fase perencanaan.', style: AppTypography.body),
          SizedBox(height: 8),
          Text('Tarik ke bawah untuk refresh.', style: AppTypography.secondary),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.lightPink),
          const SizedBox(height: 16),
          const Text('Tidak dapat memuat data fase.', style: AppTypography.body),
          const SizedBox(height: 8),
          const Text('Tarik ke bawah untuk refresh.', style: AppTypography.secondary),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.read<PhaseBloc>().add(const LoadPhases()),
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
