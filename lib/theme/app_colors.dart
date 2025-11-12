import 'package:flutter/material.dart';

/// Centralized color definitions for the AJ Store app
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2); // Deep Blue
  static const Color primaryVariant = Color(0xFF3F51B5); // Indigo
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color primaryDark = Color(0xFF004BA0);

  // Secondary Colors
  static const Color secondary = Color(0xFFFFC107); // Amber
  static const Color secondaryVariant = Color(0xFFFF9800); // Orange
  static const Color secondaryLight = Color(0xFFFFD54F);
  static const Color secondaryDark = Color(0xFFFFA000);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color background = Color(0xFFF5F5F5); // Light Gray
  static const Color card = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark Gray
  static const Color textSecondary = Color(0xFF757575); // Medium Gray
  static const Color textHint = Color(0xFFBDBDBD); // Light Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFF44336); // Red
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue

  // Additional UI Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
