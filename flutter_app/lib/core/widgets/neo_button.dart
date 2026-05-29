import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// A button widget with neobrutalist styling.
///
/// Features:
/// - 2-4px black border
/// - Pink (#FF69B4) fill
/// - 3-5px solid black offset shadow (bottom-right)
/// - Shadow reduces to 0 on press (pushed-in effect)
/// - 8-12px border radius
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.borderWidth = AppTheme.borderWidth,
    this.shadowOffset = AppTheme.shadowOffset,
    this.borderRadius = AppTheme.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final double borderWidth;
  final double shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  void _onTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveShadowOffset = _isPressed ? 0.0 : widget.shadowOffset;
    final effectiveTranslation = _isPressed
        ? Offset(widget.shadowOffset, widget.shadowOffset)
        : Offset.zero;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          effectiveTranslation.dx,
          effectiveTranslation.dy,
          0,
        ),
        decoration: BoxDecoration(
          color: _isEnabled
              ? (widget.backgroundColor ?? AppTheme.pink)
              : AppTheme.lightPink,
          border: Border.all(
            color: AppTheme.black,
            width: widget.borderWidth,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: effectiveShadowOffset > 0
              ? [
                  BoxShadow(
                    color: AppTheme.black,
                    offset: Offset(effectiveShadowOffset, effectiveShadowOffset),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: widget.padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.black,
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: AppTheme.black, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: AppTypography.button,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
