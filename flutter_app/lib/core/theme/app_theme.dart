import 'package:flutter/material.dart';

/// Neobrutalist design system color constants and theme tokens.
class AppTheme {
  AppTheme._();

  // Primary colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color pink = Color(0xFFFF69B4);
  static const Color lightPink = Color(0xFFFFB6C1);
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF333333);

  // Design tokens
  static const double borderWidth = 3.0;
  static const double shadowOffset = 4.0;
  static const double borderRadius = 10.0;

  /// Creates the app's MaterialTheme data with neobrutalist styling.
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: pink,
        secondary: lightPink,
        surface: white,
        onPrimary: black,
        onSecondary: black,
        onSurface: black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
      ),
    );
  }

  /// Standard neobrutalist box decoration for cards.
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: lightPink,
      border: Border.all(color: black, width: borderWidth),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: black,
          offset: Offset(shadowOffset, shadowOffset),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Standard neobrutalist box decoration for buttons.
  static BoxDecoration get buttonDecoration {
    return BoxDecoration(
      color: pink,
      border: Border.all(color: black, width: borderWidth),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: black,
          offset: Offset(shadowOffset, shadowOffset),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Pressed state decoration for buttons (shadow reduced to 0).
  static BoxDecoration get buttonPressedDecoration {
    return BoxDecoration(
      color: pink,
      border: Border.all(color: black, width: borderWidth),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
