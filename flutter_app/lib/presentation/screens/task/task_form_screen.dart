import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/form_validators.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../data/models/phase.dart';
import '../../../domain/blocs/task/task_bloc.dart';

/// Task form screen for adding a new task.
///
/// Validates:
/// - title: not empty, 1-255 characters
/// - phase: must be selected
/// - type: must be input or execution
/// - priority: must be rendah/sedang/tinggi
/// - Optional: description, due_date, notes
///
/// Inline error indicators auto-disappear when fields become valid.
///
/// Requirements: 7.2, 7.3, 7.9
class TaskFormScreen extends StatefulWidget {
  final List<Phase> phases;

  const TaskFormScreen({super.key, required this.phases});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedPhaseId;
  String? _selectedType;
  String? _selectedPriority;
  DateTime? _selectedDueDate;

  // Inline error messages (auto-clear when valid)
  String? _titleError;
  String? _phaseError;
  String? _typeError;
  String? _priorityError;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Validates all fields and updates inline error indicators.
  /// Returns true if all fields are valid.
  bool _validateForm() {
    bool isValid = true;

    // Title validation: 1-255 chars
    final titleError = FormValidators.requiredWithMaxLength(
      _titleController.text,
      fieldName: 'Judul',
      max: 255,
    );
    if (titleError != null) {
      isValid = false;
    }

    // Phase validation
    final phaseError = _selectedPhaseId == null ? 'Phase wajib dipilih' : null;
    if (phaseError != null) {
      isValid = false;
    }

    // Type validation
    final typeError = FormValidators.type(_selectedType);
    if (typeError != null) {
      isValid = false;
    }

    // Priority validation
    final priorityError = FormValidators.priority(_selectedPriority);
    if (priorityError != null) {
      isValid = false;
    }

    setState(() {
      _titleError = titleError;
      _phaseError = phaseError;
      _typeError = typeError;
      _priorityError = priorityError;
    });

    return isValid;
  }

  /// Called when any field changes to auto-clear errors.
  void _onFieldChanged() {
    if (_titleError != null || _phaseError != null || _typeError != null || _priorityError != null) {
      setState(() {
        // Re-validate and clear errors for valid fields
        if (_titleError != null) {
          _titleError = FormValidators.requiredWithMaxLength(
            _titleController.text,
            fieldName: 'Judul',
            max: 255,
          );
        }
        if (_phaseError != null && _selectedPhaseId != null) {
          _phaseError = null;
        }
        if (_typeError != null) {
          _typeError = FormValidators.type(_selectedType);
        }
        if (_priorityError != null) {
          _priorityError = FormValidators.priority(_selectedPriority);
        }
      });
    }
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.pink,
              onPrimary: AppTheme.white,
              surface: AppTheme.white,
              onSurface: AppTheme.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _onSubmit() {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    context.read<TaskBloc>().add(AddTask(
          phaseId: _selectedPhaseId!,
          title: _titleController.text.trim(),
          type: _selectedType!,
          category: _categoryController.text.trim().isEmpty
              ? 'general'
              : _categoryController.text.trim(),
          priority: _selectedPriority!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueDate: _selectedDueDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Tambah Task', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded && _isSubmitting) {
            // Task added successfully
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is TaskError && _isSubmitting) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phase dropdown
                _buildPhaseDropdown(),
                const SizedBox(height: 16),

                // Title field
                NeoTextField(
                  controller: _titleController,
                  label: 'Judul *',
                  hintText: 'Masukkan judul task',
                  maxLength: 255,
                  errorText: _titleError,
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: 16),

                // Type dropdown
                _buildTypeDropdown(),
                const SizedBox(height: 16),

                // Category field
                NeoTextField(
                  controller: _categoryController,
                  label: 'Kategori',
                  hintText: 'Masukkan kategori (opsional)',
                ),
                const SizedBox(height: 16),

                // Priority dropdown
                _buildPriorityDropdown(),
                const SizedBox(height: 16),

                // Due date picker
                _buildDueDatePicker(),
                const SizedBox(height: 16),

                // Description field
                NeoTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi',
                  hintText: 'Masukkan deskripsi (opsional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Notes field
                NeoTextField(
                  controller: _notesController,
                  label: 'Catatan',
                  hintText: 'Masukkan catatan (opsional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Submit button
                Center(
                  child: NeoButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    label: 'Simpan Task',
                    icon: Icons.save,
                    isLoading: _isSubmitting,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Phase dropdown with neobrutalist styling.
  Widget _buildPhaseDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phase *', style: AppTypography.caption),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: _phaseError != null ? AppTheme.pink : AppTheme.black,
              width: AppTheme.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _selectedPhaseId,
              isExpanded: true,
              hint: const Text('Pilih phase', style: AppTypography.body),
              items: widget.phases
                  .map((phase) => DropdownMenuItem<int?>(
                        value: phase.id,
                        child: Text(phase.name, style: AppTypography.body),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPhaseId = value);
                _onFieldChanged();
              },
            ),
          ),
        ),
        if (_phaseError != null) ...[
          const SizedBox(height: 4),
          Text(
            _phaseError!,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.pink,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Type dropdown with neobrutalist styling.
  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipe *', style: AppTypography.caption),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: _typeError != null ? AppTheme.pink : AppTheme.black,
              width: AppTheme.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedType,
              isExpanded: true,
              hint: const Text('Pilih tipe', style: AppTypography.body),
              items: const [
                DropdownMenuItem(
                  value: 'input',
                  child: Text('Input', style: AppTypography.body),
                ),
                DropdownMenuItem(
                  value: 'execution',
                  child: Text('Execution', style: AppTypography.body),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                _onFieldChanged();
              },
            ),
          ),
        ),
        if (_typeError != null) ...[
          const SizedBox(height: 4),
          Text(
            _typeError!,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.pink,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Priority dropdown with neobrutalist styling.
  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prioritas *', style: AppTypography.caption),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: _priorityError != null ? AppTheme.pink : AppTheme.black,
              width: AppTheme.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedPriority,
              isExpanded: true,
              hint: const Text('Pilih prioritas', style: AppTypography.body),
              items: const [
                DropdownMenuItem(
                  value: 'rendah',
                  child: Text('Rendah', style: AppTypography.body),
                ),
                DropdownMenuItem(
                  value: 'sedang',
                  child: Text('Sedang', style: AppTypography.body),
                ),
                DropdownMenuItem(
                  value: 'tinggi',
                  child: Text('Tinggi', style: AppTypography.body),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedPriority = value);
                _onFieldChanged();
              },
            ),
          ),
        ),
        if (_priorityError != null) ...[
          const SizedBox(height: 4),
          Text(
            _priorityError!,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.pink,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Due date picker with neobrutalist styling.
  Widget _buildDueDatePicker() {
    final dateText = _selectedDueDate != null
        ? DateFormat('d MMMM yyyy').format(_selectedDueDate!)
        : 'Pilih tanggal (opsional)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Jatuh Tempo', style: AppTypography.caption),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(
                color: AppTheme.black,
                width: AppTheme.borderWidth,
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateText,
                    style: _selectedDueDate != null
                        ? AppTypography.body
                        : AppTypography.body.copyWith(
                            color: AppTheme.darkGray.withValues(alpha: 0.5),
                          ),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: AppTheme.darkGray),
                if (_selectedDueDate != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedDueDate = null),
                    child: const Icon(Icons.close, size: 18, color: AppTheme.darkGray),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
