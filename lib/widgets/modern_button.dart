import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_spacing.dart';
import '../utils/animation_utils.dart';

enum ModernButtonType { elevated, outlined, text }

/// Modern button component with gradient support and loading states
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final bool isLoading;
  final bool useGradient;
  final IconData? icon;
  final double? width;
  final double? height;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ModernButtonType.elevated,
    this.isLoading = false,
    this.useGradient = false,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ModernButtonType.elevated
                    ? AppColors.textOnPrimary
                    : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.iconSM),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                text,
                style: AppTextStyles.button,
              ),
            ],
          );

    switch (type) {
      case ModernButtonType.elevated:
        return _buildElevatedButton(buttonChild, isDisabled);
      case ModernButtonType.outlined:
        return _buildOutlinedButton(buttonChild, isDisabled);
      case ModernButtonType.text:
        return _buildTextButton(buttonChild, isDisabled);
    }
  }

  Widget _buildElevatedButton(Widget child, bool isDisabled) {
    Widget button;
    
    if (useGradient && !isDisabled) {
      button = Container(
        width: width,
        height: height ?? 48,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textOnPrimary,
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
    } else {
      button = SizedBox(
        width: width,
        height: height ?? 48,
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.textHint,
            disabledForegroundColor: AppColors.textSecondary,
            elevation: AppSpacing.elevationSM,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
          ),
          child: child,
        ),
      );
    }

    // Add scale animation for non-disabled buttons
    if (!isDisabled) {
      return ScaleAnimation(
        onTap: onPressed,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildOutlinedButton(Widget child, bool isDisabled) {
    Widget button = SizedBox(
      width: width,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textSecondary,
          side: BorderSide(
            color: isDisabled ? AppColors.textHint : AppColors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
        ),
        child: child,
      ),
    );

    // Add scale animation for non-disabled buttons
    if (!isDisabled) {
      return ScaleAnimation(
        onTap: onPressed,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildTextButton(Widget child, bool isDisabled) {
    Widget button = SizedBox(
      width: width,
      height: height ?? 48,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
        ),
        child: child,
      ),
    );

    // Add scale animation for non-disabled buttons
    if (!isDisabled) {
      return ScaleAnimation(
        onTap: onPressed,
        child: button,
      );
    }
    
    return button;
  }
}
