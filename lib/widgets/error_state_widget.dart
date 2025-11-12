import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_spacing.dart';
import 'modern_button.dart';

/// Widget for displaying error states with retry functionality
class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryButtonText,
  });

  /// Factory constructor for network errors
  factory ErrorStateWidget.network({
    VoidCallback? onRetry,
    String? retryButtonText,
  }) {
    return ErrorStateWidget(
      title: 'Connection Error',
      message: 'Unable to connect to the server.\nPlease check your internet connection and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      retryButtonText: retryButtonText,
    );
  }

  /// Factory constructor for general errors
  factory ErrorStateWidget.general({
    String? title,
    String? message,
    VoidCallback? onRetry,
    String? retryButtonText,
  }) {
    return ErrorStateWidget(
      title: title ?? 'Something Went Wrong',
      message: message ?? 'An unexpected error occurred.\nPlease try again.',
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
      retryButtonText: retryButtonText,
    );
  }

  /// Factory constructor for not found errors
  factory ErrorStateWidget.notFound({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      title: title ?? 'Not Found',
      message: message ?? 'The requested content could not be found.',
      icon: Icons.search_off_rounded,
      onRetry: onRetry,
    );
  }

  /// Factory constructor for permission errors
  factory ErrorStateWidget.permission({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      title: 'Permission Denied',
      message: message ?? 'You don\'t have permission to access this content.',
      icon: Icons.lock_outline_rounded,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            if (title != null)
              Text(
                title!,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
            
            if (title != null) const SizedBox(height: AppSpacing.sm),

            // Message
            if (message != null)
              Text(
                message!,
                style: AppTextStyles.bodyMediumSecondary,
                textAlign: TextAlign.center,
              ),

            if (onRetry != null) const SizedBox(height: AppSpacing.xl),

            // Retry Button
            if (onRetry != null)
              ModernButton(
                text: retryButtonText ?? 'Try Again',
                onPressed: onRetry,
                type: ModernButtonType.elevated,
                icon: Icons.refresh_rounded,
              ),
          ],
        ),
      ),
    );
  }
}
