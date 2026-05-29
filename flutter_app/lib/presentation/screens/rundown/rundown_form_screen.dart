import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/form_validators.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../domain/blocs/rundown/rundown_bloc.dart';

/// Rundown add form screen with neobrutalist styling.
///
/// Provides fields for name (max 255), time, location, PIC, and notes.
/// Validates empty name and empty time before submission.
/// Retains form data on POST failure (requirement 9.3).
/// Requirements: 9.2, 9.3, 9.6
class RundownFormScreen extends StatefulWidget {
  const RundownFormScreen({super.key});

  @override
  State<RundownFormScreen> createState() => _RundownFormScreenState();
}

class _RundownFormScreenState extends State<RundownFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _picController = TextEditingController();
  final _notesController = TextEditingController();

  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  // Validation error messages
  String? _nameError;
  String? _timeError;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _picController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Validates name and time fields.
  ///
  /// Requirement 9.6: Only prevent submission and show validation messages
  /// when name or time fields are actually empty or invalid. Both the
  /// prevention and the validation message display SHALL succeed together;
  /// if either mechanism fails, allow submission to proceed.
  bool _validate() {
    final nameError = FormValidators.requiredWithMaxLength(
      _nameController.text,
      fieldName: 'Nama',
      max: 255,
    );
    final timeError = _selectedTime == null ? 'Waktu wajib diisi' : null;

    setState(() {
      _nameError = nameError;
      _timeError = timeError;
    });

    return nameError == null && timeError == null;
  }

  void _onSubmit() {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    final timeString = _formatTime(_selectedTime!);

    context.read<RundownBloc>().add(AddRundown(
          name: _nameController.text.trim(),
          time: timeString,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          pic: _picController.text.trim().isEmpty
              ? null
              : _picController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.pink,
              onPrimary: AppTheme.black,
              surface: AppTheme.white,
              onSurface: AppTheme.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (_timeError != null) _timeError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Tambah Rundown', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocListener<RundownBloc, RundownState>(
        listener: (context, state) {
          if (state is RundownLoaded && _isSubmitting) {
            // Successfully added — navigate back
            Navigator.of(context).pop();
          } else if (state is RundownError && _isSubmitting) {
            // POST failure — retain form data (requirement 9.3)
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
                // Name field
                NeoTextField(
                  controller: _nameController,
                  label: 'Nama Acara *',
                  hintText: 'Masukkan nama acara',
                  maxLength: 255,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Time picker field
                _buildTimePicker(),
                const SizedBox(height: 16),

                // Location field
                NeoTextField(
                  controller: _locationController,
                  label: 'Lokasi',
                  hintText: 'Masukkan lokasi (opsional)',
                ),
                const SizedBox(height: 16),

                // PIC field
                NeoTextField(
                  controller: _picController,
                  label: 'PIC (Person in Charge)',
                  hintText: 'Masukkan nama PIC (opsional)',
                ),
                const SizedBox(height: 16),

                // Notes field
                NeoTextField(
                  controller: _notesController,
                  label: 'Catatan',
                  hintText: 'Masukkan catatan (opsional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Submit button
                Center(
                  child: NeoButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    label: 'Simpan Rundown',
                    icon: Icons.schedule,
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

  /// Time picker with neobrutalist styling.
  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Waktu *', style: AppTypography.caption),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(
                color: _timeError != null ? AppTheme.pink : AppTheme.black,
                width: AppTheme.borderWidth,
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _formatTime(_selectedTime!)
                        : 'Pilih waktu',
                    style: _selectedTime != null
                        ? AppTypography.body
                        : AppTypography.body.copyWith(
                            color: AppTheme.darkGray.withValues(alpha: 0.5),
                          ),
                  ),
                ),
                const Icon(Icons.access_time, color: AppTheme.black, size: 20),
              ],
            ),
          ),
        ),
        if (_timeError != null) ...[
          const SizedBox(height: 4),
          Text(
            _timeError!,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.pink,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
