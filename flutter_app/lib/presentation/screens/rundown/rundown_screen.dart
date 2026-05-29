import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/rundown.dart';
import '../../../domain/blocs/rundown/rundown_bloc.dart';
import 'rundown_form_screen.dart';

/// Rundown list screen displaying all wedding day schedule items.
///
/// Shows items ordered by time ascending with name, time, location (or empty),
/// and PIC (or empty). Supports pull-to-refresh and delete with confirmation.
/// Requirements: 9.1, 9.4, 9.5
class RundownScreen extends StatefulWidget {
  const RundownScreen({super.key});

  @override
  State<RundownScreen> createState() => _RundownScreenState();
}

class _RundownScreenState extends State<RundownScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RundownBloc>().add(const LoadRundowns());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<RundownBloc>();
    bloc.add(const LoadRundowns());
    await bloc.stream.firstWhere(
      (state) => state is! RundownLoading,
    );
  }

  void _navigateToAddRundown() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RundownFormScreen()),
    );
  }

  void _showDeleteConfirmation(Rundown rundown) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(
            color: AppTheme.black,
            width: AppTheme.borderWidth,
          ),
        ),
        title: const Text('Hapus Rundown', style: AppTypography.h4),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${rundown.name}" dari rundown?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Batal',
              style: AppTypography.body.copyWith(color: AppTheme.darkGray),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<RundownBloc>().add(DeleteRundown(id: rundown.id));
            },
            child: Text(
              'Hapus',
              style: AppTypography.body.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
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
        title: const Text('Rundown', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<RundownBloc, RundownState>(
        listener: (context, state) {
          if (state is RundownError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RundownLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          final rundowns = _getRundowns(state);

          return RefreshIndicator(
            color: AppTheme.pink,
            onRefresh: _onRefresh,
            child: rundowns.isEmpty
                ? _buildEmptyState()
                : _buildRundownList(rundowns),
          );
        },
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  List<Rundown> _getRundowns(RundownState state) {
    if (state is RundownLoaded) return state.rundowns;
    if (state is RundownError) return state.rundowns;
    return [];
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(Icons.schedule_outlined, size: 64, color: AppTheme.lightPink),
              SizedBox(height: 16),
              Text('Belum ada rundown.', style: AppTypography.body),
              SizedBox(height: 8),
              Text(
                'Tap + untuk menambah acara baru.',
                style: AppTypography.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRundownList(List<Rundown> rundowns) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rundowns.map((rundown) => _buildRundownItem(rundown)),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  /// Individual rundown item card showing name, time, location, and PIC.
  /// Requirement 9.1
  Widget _buildRundownItem(Rundown rundown) {
    return NeoCard(
      backgroundColor: AppTheme.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.lightPink,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.black, width: 1.5),
            ),
            child: Text(
              rundown.time,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rundown.name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (rundown.location != null &&
                        rundown.location!.isNotEmpty) ...[
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppTheme.darkGray),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          rundown.location!,
                          style: AppTypography.secondary.copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (rundown.pic != null && rundown.pic!.isNotEmpty) ...[
                      const Icon(Icons.person_outline,
                          size: 14, color: AppTheme.darkGray),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          rundown.pic!,
                          style: AppTypography.secondary.copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            onPressed: () => _showDeleteConfirmation(rundown),
            tooltip: 'Hapus rundown',
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return NeoButton(
      onPressed: _navigateToAddRundown,
      label: '+',
      padding: const EdgeInsets.all(16),
    );
  }
}
