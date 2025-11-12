import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_spacing.dart';

/// Modern card component with consistent styling, elevation, and rounded corners
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final Border? border;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.color,
    this.onTap,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusLG,
        ),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: (elevation ?? AppSpacing.elevationSM) * 2,
            offset: Offset(0, elevation ?? AppSpacing.elevationSM),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSpacing.radiusLG,
            ),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardContent,
    );
  }
}
