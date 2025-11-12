import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography definitions for the AJ Store app
class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Special Styles
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Variants with different colors
  static const TextStyle bodyLargeBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMediumSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle h1White = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );

  static const TextStyle h2White = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLargeWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textOnPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMediumWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textOnPrimary,
    height: 1.5,
  );

  static const TextStyle captionWhite = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );

  // Price Text
  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
  );
}
