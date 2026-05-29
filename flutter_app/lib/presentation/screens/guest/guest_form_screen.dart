import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/form_validators.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../domain/blocs/guest/guest_bloc.dart';

/// Guest add form screen with neobrutalist styling.
///
/// Provides fields for name (max 255), side (Pria/Wanita/Keluarga),
/// phone, email, and status (Belum Diundang/Diundang/Konfirmasi/Hadir).
/// Validates empty name and invalid side value before submission.
/// Requirements: 5.3, 5.5, 5.6
class GuestFormScreen extends StatefulWidget {
  const GuestFormScreen({super.key});

  @override
  State<GuestFormScreen> createState() => _GuestFormScreenState();
}

class _GuestFormScreenState extends State<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedSide;
  String _selectedStatus = 'Belum Diundang';
  bool _isSubmitting = false;

  // Validation error messages
  String? _nameError;
  String? _sideError;

  static const List<String> _sideOptions = ['Pria', 'Wanita', 'Keluarga'];
  static const List<String> _statusOptions = [
    'Belum Diundang',
    'Diundang',
    'Konfirmasi',
    'Hadir',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    final nameError = FormValidators.requiredWithMaxLength(
      _nameController.text,
      fieldName: 'Nama',
      max: 255,
    );
    final sideError = FormValidators.side(_selectedSide);

    setState(() {
      _nameError = nameError;
      _sideError = sideError;
    });

    return nameError == null && sideError == null;
  }

  void _onSubmit() {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    context.read<GuestBloc>().add(AddGuest(
          name: _nameController.text.trim(),
          side: _selectedSide!,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          status: _selectedStatus,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Tambah Tamu', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocListener<GuestBloc, GuestState>(
        listener: (context, state) {
          if (state is GuestLoaded && _isSubmitting) {
            // Successfully added — navigate back
            Navigator.of(context).pop();
          } else if (state is GuestError && _isSubmitting) {
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
                  label: 'Nama Tamu *',
                  hintText: 'Masukkan nama tamu',
                  maxLength: 255,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Side dropdown
                _buildSideDropdown(),
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

                // Status dropdown
                _buildStatusDropdown(),
                const SizedBox(height: 32),

                // Submit button
                Center(
                  child: NeoButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    label: 'Simpan Tamu',
                    icon: Icons.person_add,
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

  /// Side dropdown with neobrutalist styling.
  Widget _buildSideDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sisi *', style: AppTypography.caption),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: _sideError != null ? AppTheme.pink : AppTheme.black,
              width: AppTheme.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSide,
              hint: Text(
                'Pilih sisi',
                style: AppTypography.body.copyWith(
                  color: AppTheme.darkGray.withValues(alpha: 0.5),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.black),
              items: _sideOptions.map((side) {
                return DropdownMenuItem<String>(
                  value: side,
                  child: Text(side, style: AppTypography.body),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSide = value;
                  if (_sideError != null) _sideError = null;
                });
              },
            ),
          ),
        ),
        if (_sideError != null) ...[
          const SizedBox(height: 4),
          Text(
            _sideError!,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.pink,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Status dropdown with neobrutalist styling.
  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: AppTypography.caption),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: AppTheme.black,
              width: AppTheme.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.black),
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status, style: AppTypography.body),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
