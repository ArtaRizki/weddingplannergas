import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/phase.dart';
import '../../../data/models/task.dart';
import '../../../data/repositories/phase_repository.dart';
import '../../../domain/blocs/task/task_bloc.dart';
import 'task_form_screen.dart';

/// Task list screen displaying all tasks ordered by due date.
///
/// Features:
/// - Filter by phase dropdown
/// - Visually distinguish completed tasks (strikethrough/reduced opacity)
/// - Visually indicate overdue tasks (distinct color/icon)
/// - Toggle task completion via tap
/// - Confirmation dialog for delete
/// - Neobrutalist styling
///
/// Requirements: 7.1, 7.2, 7.4, 7.5, 7.6, 7.7, 7.8
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Phase> _phases = [];
  bool _phasesLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasks());
    _loadPhases();
  }

  Future<void> _loadPhases() async {
    try {
      final phases = await PhaseRepository().getAll();
      if (mounted) {
        setState(() {
          _phases = phases;
          _phasesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _phasesLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<TaskBloc>();
    bloc.add(const LoadTasks());
    await bloc.stream.firstWhere((state) => state is! TaskLoading);
  }

  void _onFilterChanged(int? phaseId) {
    context.read<TaskBloc>().add(FilterByPhase(phaseId: phaseId));
  }

  void _onToggleTask(int taskId) {
    context.read<TaskBloc>().add(ToggleTask(taskId: taskId));
  }

  Future<void> _onDeleteTask(int taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
        ),
        title: const Text('Hapus Task', style: AppTypography.h4),
        content: const Text(
          'Apakah Anda yakin ingin menghapus task ini?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: AppTypography.body.copyWith(color: AppTheme.darkGray)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus', style: AppTypography.body.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TaskBloc>().add(DeleteTask(taskId: taskId));
    }
  }

  void _navigateToAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: TaskFormScreen(phases: _phases),
        ),
      ),
    );
  }

  /// Determines if a task is overdue (due_date < today and not completed).
  bool _isOverdue(Task task) {
    if (task.isCompleted || task.dueDate == null) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return task.dueDate!.isBefore(todayDate);
  }

  /// Gets the phase name for a given phase ID.
  String _getPhaseName(int phaseId) {
    final phase = _phases.where((p) => p.id == phaseId).firstOrNull;
    return phase?.name ?? 'Phase $phaseId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Tasks', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          final tasks = _getDisplayTasks(state);
          final filterPhaseId = _getFilterPhaseId(state);

          return RefreshIndicator(
            color: AppTheme.pink,
            onRefresh: _onRefresh,
            child: Column(
              children: [
                _buildFilterBar(filterPhaseId),
                Expanded(
                  child: tasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) =>
                              _buildTaskItem(tasks[index]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  /// Extracts the displayable task list from the current state.
  List<Task> _getDisplayTasks(TaskState state) {
    if (state is TaskLoaded) return state.filteredTasks;
    if (state is TaskError && state.previousTasks != null) {
      // Apply filter manually for error state
      final filter = state.filterPhaseId;
      var tasks = filter != null
          ? state.previousTasks!.where((t) => t.phaseId == filter).toList()
          : List<Task>.from(state.previousTasks!);
      tasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      return tasks;
    }
    return [];
  }

  /// Extracts the current filter phase ID from the state.
  int? _getFilterPhaseId(TaskState state) {
    if (state is TaskLoaded) return state.filterPhaseId;
    if (state is TaskError) return state.filterPhaseId;
    return null;
  }

  /// Phase filter dropdown bar.
  Widget _buildFilterBar(int? currentFilter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.black, width: 2),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: currentFilter,
            isExpanded: true,
            hint: const Text('Semua Phase', style: AppTypography.body),
            icon: const Icon(Icons.filter_list, color: AppTheme.black),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Semua Phase', style: AppTypography.body),
              ),
              if (!_phasesLoading)
                ..._phases.map((phase) => DropdownMenuItem<int?>(
                      value: phase.id,
                      child: Text(phase.name, style: AppTypography.body),
                    )),
            ],
            onChanged: _onFilterChanged,
          ),
        ),
      ),
    );
  }

  /// Empty state when no tasks are available.
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Icon(Icons.task_alt, size: 64, color: AppTheme.lightPink),
              SizedBox(height: 16),
              Text('Belum ada task.', style: AppTypography.body),
              SizedBox(height: 8),
              Text(
                'Tap + untuk menambah task baru.',
                style: AppTypography.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Individual task card item.
  Widget _buildTaskItem(Task task) {
    final isOverdue = _isOverdue(task);
    final isCompleted = task.isCompleted;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _onDeleteTask(task.id);
        return false; // We handle deletion via bloc
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: NeoCard(
        backgroundColor: isCompleted
            ? AppTheme.lightPink.withValues(alpha: 0.5)
            : isOverdue
                ? const Color(0xFFFFF0F0)
                : AppTheme.white,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        child: Opacity(
          opacity: isCompleted ? 0.6 : 1.0,
          child: InkWell(
            onTap: () => _onToggleTask(task.id),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion checkbox
                _buildCheckbox(task),
                const SizedBox(width: 12),
                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with strikethrough for completed
                      Text(
                        task.title,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppTheme.darkGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Metadata row: type, priority, phase
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildChip(
                            task.type == 'input' ? 'Input' : 'Execution',
                            task.type == 'input'
                                ? Colors.blue.shade100
                                : Colors.green.shade100,
                          ),
                          _buildPriorityChip(task.priority),
                          _buildChip(
                            _getPhaseName(task.phaseId),
                            AppTheme.lightPink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Due date row
                      _buildDueDateRow(task, isOverdue),
                    ],
                  ),
                ),
                // Overdue indicator
                if (isOverdue)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Checkbox widget for task completion toggle.
  Widget _buildCheckbox(Task task) {
    return GestureDetector(
      onTap: () => _onToggleTask(task.id),
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppTheme.pink : AppTheme.white,
          border: Border.all(color: AppTheme.black, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: task.isCompleted
            ? const Icon(Icons.check, size: 16, color: AppTheme.white)
            : null,
      ),
    );
  }

  /// Small chip widget for metadata display.
  Widget _buildChip(String label, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.black, width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.body.copyWith(fontSize: 11),
      ),
    );
  }

  /// Priority chip with color coding.
  Widget _buildPriorityChip(String priority) {
    Color bgColor;
    switch (priority) {
      case 'tinggi':
        bgColor = Colors.red.shade100;
        break;
      case 'sedang':
        bgColor = Colors.orange.shade100;
        break;
      default:
        bgColor = Colors.grey.shade200;
    }
    final label = priority[0].toUpperCase() + priority.substring(1);
    return _buildChip(label, bgColor);
  }

  /// Due date row with overdue styling.
  Widget _buildDueDateRow(Task task, bool isOverdue) {
    if (task.dueDate == null) {
      return Text(
        'No due date',
        style: AppTypography.secondary.copyWith(fontSize: 12),
      );
    }

    final dateText = DateFormat('d MMM yyyy').format(task.dueDate!);
    return Row(
      children: [
        Icon(
          isOverdue ? Icons.schedule : Icons.calendar_today,
          size: 12,
          color: isOverdue ? Colors.red : AppTheme.darkGray,
        ),
        const SizedBox(width: 4),
        Text(
          dateText,
          style: AppTypography.secondary.copyWith(
            fontSize: 12,
            color: isOverdue ? Colors.red : AppTheme.darkGray,
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (isOverdue) ...[
          const SizedBox(width: 4),
          Text(
            '(Overdue)',
            style: AppTypography.secondary.copyWith(
              fontSize: 11,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Floating action button to add a new task.
  Widget _buildAddButton() {
    return NeoButton(
      onPressed: _navigateToAddTask,
      label: '+',
      padding: const EdgeInsets.all(16),
    );
  }
}
