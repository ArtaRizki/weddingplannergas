import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/form_validators.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../data/models/wedding.dart';
import '../../../domain/blocs/settings/settings_bloc.dart';

/// Settings screen for editing wedding details.
///
/// Displays a form pre-filled with groom name, bride name, wedding date,
/// location, and total budget. Validates input immediately when fields
/// become empty and on submission.
///
/// Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _groomNameController;
  late final TextEditingController _brideNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _budgetController;

  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  // Validation error messages
  String? _groomNameError;
  String? _brideNameError;
  String? _locationError;
  String? _budgetError;

  @override
  void initState() {
    super.initState();
    _groomNameController = TextEditingController();
    _brideNameController = TextEditingController();
    _locationController = TextEditingController();
    _budgetController = TextEditingController();

    // Load settings on screen open
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  @override
  void dispose() {
    _groomNameController.dispose();
    _brideNameController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Populates form fields from the loaded Wedding settings.
  void _populateForm(Wedding settings) {
    if (!_isInitialized) {
      _groomNameController.text = settings.groomName;
      _brideNameController.text = settings.brideName;
      _locationController.text = settings.location ?? '';
      _budgetController.text = settings.totalBudget.toString();
      _selectedDate = settings.weddingDate;
      _isInitialized = true;
    }
  }

  /// Validates groom name immediately when field changes.
  void _validateGroomName(String value) {
    setState(() {
      _groomNameError = FormValidators.requiredWithMaxLength(
        value,
        fieldName: 'Nama mempelai pria',
        max: 255,
      );
    });
  }

  /// Validates bride name immediately when field changes.
  void _validateBrideName(String value) {
    setState(() {
      _brideNameError = FormValidators.requiredWithMaxLength(
        value,
        fieldName: 'Nama mempelai wanita',
        max: 255,
      );
    });
  }

  /// Validates location when field changes (max 255, not required).
  void _validateLocation(String value) {
    setState(() {
      _locationError = FormValidators.maxLength(
        value,
        255,
        fieldName: 'Lokasi',
      );
    });
  }

  /// Validates budget when field changes.
  void _validateBudget(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _budgetError = null;
        return;
      }
      final numericError = FormValidators.numeric(
        value,
        fieldName: 'Total budget',
      );
      if (numericError != null) {
        _budgetError = numericError;
        return;
      }
      final nonNegError = FormValidators.nonNegative(
        value,
        fieldName: 'Total budget',
      );
      if (nonNegError != null) {
        _budgetError = nonNegError;
        return;
      }
      final maxError = FormValidators.maxValue(
        value,
        9999999999999.99,
        fieldName: 'Total budget',
      );
      if (maxError != null) {
        _budgetError = maxError;
        return;
      }
      _budgetError = null;
    });
  }

  /// Validates all fields and returns true if all are valid.
  bool _validateAll() {
    final groomError = FormValidators.requiredWithMaxLength(
      _groomNameController.text,
      fieldName: 'Nama mempelai pria',
      max: 255,
    );
    final brideError = FormValidators.requiredWithMaxLength(
      _brideNameController.text,
      fieldName: 'Nama mempelai wanita',
      max: 255,
    );
    final locationError = FormValidators.maxLength(
      _locationController.text,
      255,
      fieldName: 'Lokasi',
    );

    String? budgetError;
    final budgetText = _budgetController.text.trim();
    if (budgetText.isNotEmpty) {
      budgetError = FormValidators.numeric(budgetText, fieldName: 'Total budget');
      budgetError ??= FormValidators.nonNegative(budgetText, fieldName: 'Total budget');
      budgetError ??= FormValidators.maxValue(
        budgetText,
        9999999999999.99,
        fieldName: 'Total budget',
      );
    }

    setState(() {
      _groomNameError = groomError;
      _brideNameError = brideError;
      _locationError = locationError;
      _budgetError = budgetError;
    });

    return groomError == null &&
        brideError == null &&
        locationError == null &&
        budgetError == null;
  }

  void _onSubmit() {
    if (!_validateAll()) return;

    setState(() => _isSubmitting = true);

    final groomName = _groomNameController.text.trim();
    final brideName = _brideNameController.text.trim();
    final location = _locationController.text.trim().isEmpty
        ? null
        : _locationController.text.trim();
    final budgetText = _budgetController.text.trim();
    final totalBudget = budgetText.isEmpty ? 0.0 : double.parse(budgetText);

    context.read<SettingsBloc>().add(UpdateSettings(
          groomName: groomName,
          brideName: brideName,
          weddingDate: _selectedDate,
          location: location,
          totalBudget: totalBudget,
        ));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belum dipilih';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Pengaturan', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsSuccess) {
            setState(() => _isSubmitting = false);
            // Re-populate form with updated data
            _isInitialized = false;
            _populateForm(state.settings);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
              ),
            );
          } else if (state is SettingsError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          } else if (state is SettingsLoaded) {
            _populateForm(state.settings);
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading && !_isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeoCard(
                    backgroundColor: AppTheme.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Pernikahan', style: AppTypography.h4),
                        const SizedBox(height: 16),
                        NeoTextField(
                          controller: _groomNameController,
                          label: 'Nama Mempelai Pria',
                          hintText: 'Masukkan nama mempelai pria',
                          maxLength: 255,
                          errorText: _groomNameError,
                          onChanged: _validateGroomName,
                        ),
                        const SizedBox(height: 16),
                        NeoTextField(
                          controller: _brideNameController,
                          label: 'Nama Mempelai Wanita',
                          hintText: 'Masukkan nama mempelai wanita',
                          maxLength: 255,
                          errorText: _brideNameError,
                          onChanged: _validateBrideName,
                        ),
                        const SizedBox(height: 16),
                        // Wedding date picker
                        const Text('Tanggal Pernikahan', style: AppTypography.caption),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              border: Border.all(
                                color: AppTheme.black,
                                width: AppTheme.borderWidth,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(_selectedDate),
                                  style: _selectedDate != null
                                      ? AppTypography.body
                                      : AppTypography.body.copyWith(
                                          color: AppTheme.darkGray
                                              .withValues(alpha: 0.5),
                                        ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.darkGray,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        NeoTextField(
                          controller: _locationController,
                          label: 'Lokasi',
                          hintText: 'Masukkan lokasi pernikahan',
                          maxLength: 255,
                          errorText: _locationError,
                          onChanged: _validateLocation,
                        ),
                        const SizedBox(height: 16),
                        NeoTextField(
                          controller: _budgetController,
                          label: 'Total Budget',
                          hintText: 'Contoh: 50000000',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          errorText: _budgetError,
                          onChanged: _validateBudget,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: NeoButton(
                      onPressed: _isSubmitting ? null : _onSubmit,
                      label: 'Simpan Pengaturan',
                      icon: Icons.save,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
