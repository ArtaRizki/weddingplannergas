import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Typography definitions for the Neobrutalist design system.
///
/// Headings use bold sans-serif (weight 700+).
/// Body text uses regular sans-serif with minimum 14px size.
class AppTypography {
  AppTypography._();

  // Heading styles — bold sans-serif, weight 700+
  static const TextStyle h1 = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppTheme.black,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppTheme.black,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppTheme.black,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppTheme.black,
    height: 1.4,
  );

  // Body styles — regular sans-serif, minimum 14px
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppTheme.black,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.black,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.darkGray,
    height: 1.5,
  );

  // Secondary text — dark gray for supporting text
  static const TextStyle secondary = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.darkGray,
    height: 1.5,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppTheme.black,
    height: 1.2,
  );

  // Caption / label
  static const TextStyle caption = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppTheme.darkGray,
    height: 1.4,
  );
}
