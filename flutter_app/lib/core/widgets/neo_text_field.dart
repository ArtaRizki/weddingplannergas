import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// A text input field with neobrutalist styling.
///
/// Features:
/// - 2-4px black border
/// - 8-12px border radius
/// - White background
/// - Bold label text
/// - Error state with pink highlight
class NeoTextField extends StatelessWidget {
  const NeoTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.borderWidth = AppTheme.borderWidth,
    this.borderRadius = AppTheme.borderRadius,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final double borderWidth;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.caption),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: errorText != null ? AppTheme.pink : AppTheme.black,
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            maxLines: maxLines,
            onChanged: onChanged,
            validator: validator,
            enabled: enabled,
            style: AppTypography.body.copyWith(color: AppTheme.black),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.body.copyWith(
                color: AppTheme.darkGray.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              counterText: '',
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
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
