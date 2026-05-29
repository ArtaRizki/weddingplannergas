import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/form_validators.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../data/models/budget.dart';
import '../../../domain/blocs/budget/budget_bloc.dart';

/// Budget add/edit form screen.
///
/// When [budget] is null, the form is in "add" mode.
/// When [budget] is provided, the form is in "edit" mode with pre-filled values.
/// Requirements: 4.3, 4.4, 4.6, 4.7
class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({super.key, this.budget});

  /// If provided, the form is in edit mode with pre-filled values.
  final Budget? budget;

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _categoryController;
  late final TextEditingController _plannedController;
  late final TextEditingController _actualController;

  String? _categoryError;
  String? _plannedError;
  String? _actualError;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.budget != null;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(
      text: widget.budget?.category ?? '',
    );
    _plannedController = TextEditingController(
      text: widget.budget != null ? widget.budget!.plannedAmount.toString() : '',
    );
    _actualController = TextEditingController(
      text: widget.budget != null ? widget.budget!.actualAmount.toString() : '',
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _plannedController.dispose();
    _actualController.dispose();
    super.dispose();
  }

  /// Validates all fields and returns true if all are valid.
  bool _validate() {
    final categoryError = FormValidators.requiredWithMaxLength(
      _categoryController.text,
      fieldName: 'Kategori',
      max: 255,
    );
    final plannedError = FormValidators.budgetAmount(
      _plannedController.text,
      fieldName: 'Jumlah rencana',
    );
    final actualError = FormValidators.budgetAmount(
      _actualController.text,
      fieldName: 'Jumlah aktual',
    );

    setState(() {
      _categoryError = categoryError;
      _plannedError = plannedError;
      _actualError = actualError;
    });

    return categoryError == null && plannedError == null && actualError == null;
  }

  void _onSubmit() {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    final category = _categoryController.text.trim();
    final planned = double.parse(_plannedController.text.trim());
    final actual = double.parse(_actualController.text.trim());

    if (_isEditMode) {
      context.read<BudgetBloc>().add(UpdateBudget(
            id: widget.budget!.id,
            category: category,
            plannedAmount: planned,
            actualAmount: actual,
          ));
    } else {
      context.read<BudgetBloc>().add(AddBudget(
            category: category,
            plannedAmount: planned,
            actualAmount: actual,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Budget' : 'Tambah Budget',
          style: AppTypography.h3,
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocListener<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetLoaded) {
            // Operation succeeded, navigate back
            Navigator.of(context).pop();
          } else if (state is BudgetError) {
            // Operation failed, show error and preserve form data
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
                NeoCard(
                  backgroundColor: AppTheme.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeoTextField(
                        controller: _categoryController,
                        label: 'Nama Kategori',
                        hintText: 'Contoh: Catering, Dekorasi',
                        maxLength: 255,
                        errorText: _categoryError,
                        onChanged: (_) {
                          if (_categoryError != null) {
                            setState(() => _categoryError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      NeoTextField(
                        controller: _plannedController,
                        label: 'Jumlah Rencana',
                        hintText: 'Contoh: 5000000',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        errorText: _plannedError,
                        onChanged: (_) {
                          if (_plannedError != null) {
                            setState(() => _plannedError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      NeoTextField(
                        controller: _actualController,
                        label: 'Jumlah Aktual',
                        hintText: 'Contoh: 4500000',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        errorText: _actualError,
                        onChanged: (_) {
                          if (_actualError != null) {
                            setState(() => _actualError = null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: NeoButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    label: _isEditMode ? 'Simpan Perubahan' : 'Tambah Budget',
                    icon: _isEditMode ? Icons.save : Icons.add,
                    isLoading: _isSubmitting,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
