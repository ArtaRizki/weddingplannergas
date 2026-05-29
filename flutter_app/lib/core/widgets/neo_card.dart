import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A card widget with neobrutalist styling.
///
/// Features:
/// - 2-4px black border
/// - 3-5px solid black offset shadow (bottom-right)
/// - 8-12px border radius
/// - Light pink background by default
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.backgroundColor,
    this.borderWidth = AppTheme.borderWidth,
    this.shadowOffset = AppTheme.shadowOffset,
    this.borderRadius = AppTheme.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final double borderWidth;
  final double shadowOffset;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.lightPink,
        border: Border.all(
          color: AppTheme.black,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
