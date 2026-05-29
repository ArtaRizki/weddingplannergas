import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/form_validators.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../domain/blocs/vendor/vendor_bloc.dart';

/// Vendor add form screen with neobrutalist styling.
///
/// Provides fields for name (max 255), category, phone, email, and cost.
/// Validates empty name, empty category, and non-numeric/negative cost.
/// Validation errors only appear during form submission attempts (requirement 8.4).
/// Requirements: 8.2, 8.4, 8.5, 8.6
class VendorFormScreen extends StatefulWidget {
  const VendorFormScreen({super.key});

  @override
  State<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends State<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _costController = TextEditingController();

  bool _isSubmitting = false;

  // Validation error messages — only shown after submission attempt
  String? _nameError;
  String? _categoryError;
  String? _costError;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _costController.dispose();
    super.dispose();
  }

  /// Validates all required fields. Returns true if all valid.
  /// Validation errors SHALL only appear during form submission attempts (req 8.4).
  bool _validate() {
    final nameError = FormValidators.requiredWithMaxLength(
      _nameController.text,
      fieldName: 'Nama',
      max: 255,
    );
    final categoryError = FormValidators.required(
      _categoryController.text,
      fieldName: 'Kategori',
    );
    final costError = _validateCost(_costController.text);

    setState(() {
      _nameError = nameError;
      _categoryError = categoryError;
      _costError = costError;
    });

    return nameError == null && categoryError == null && costError == null;
  }

  /// Validates cost field: must be numeric and non-negative (req 8.5).
  String? _validateCost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Biaya wajib diisi';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Biaya harus berupa angka';
    }
    if (number < 0) {
      return 'Biaya tidak boleh negatif';
    }
    return null;
  }

  void _onSubmit() {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    final cost = double.parse(_costController.text.trim());

    context.read<VendorBloc>().add(AddVendor(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          cost: cost,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Tambah Vendor', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocListener<VendorBloc, VendorState>(
        listener: (context, state) {
          if (state is VendorLoaded && _isSubmitting) {
            // Successfully added — navigate back
            Navigator.of(context).pop();
          } else if (state is VendorError && _isSubmitting) {
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
                  label: 'Nama Vendor *',
                  hintText: 'Masukkan nama vendor',
                  maxLength: 255,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Category field
                NeoTextField(
                  controller: _categoryController,
                  label: 'Kategori *',
                  hintText: 'Masukkan kategori (misal: Catering, Dekorasi)',
                  errorText: _categoryError,
                  onChanged: (_) {
                    if (_categoryError != null) {
                      setState(() => _categoryError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Phone field
                NeoTextField(
                  controller: _phoneController,
                  label: 'Telepon',
                  hintText: 'Masukkan nomor telepon',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Email field
                NeoTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Masukkan alamat email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Cost field
                NeoTextField(
                  controller: _costController,
                  label: 'Biaya *',
                  hintText: 'Masukkan biaya vendor',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  errorText: _costError,
                  onChanged: (_) {
                    if (_costError != null) {
                      setState(() => _costError = null);
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Submit button
                Center(
                  child: NeoButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    label: 'Simpan Vendor',
                    icon: Icons.store,
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
}
