import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_spacing.dart';
import 'modern_button.dart';

/// Widget for displaying empty states for lists and no data scenarios
class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionButtonText;
  final Widget? illustration;
  
  // Alternative parameter names for compatibility
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onAction,
    this.actionButtonText,
    this.illustration,
    this.actionLabel,
    this.onActionPressed,
  });

  /// Factory constructor for empty product list
  factory EmptyStateWidget.noProducts({
    VoidCallback? onAction,
    String? actionButtonText,
  }) {
    return EmptyStateWidget(
      title: 'No Products Found',
      message: 'There are no products available at the moment.\nCheck back later or try adjusting your filters.',
      icon: Icons.inventory_2_outlined,
      onAction: onAction,
      actionButtonText: actionButtonText,
    );
  }

  /// Factory constructor for empty search results
  factory EmptyStateWidget.noSearchResults({
    String? searchQuery,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: 'No Results Found',
      message: searchQuery != null
          ? 'We couldn\'t find any products matching "$searchQuery".\nTry different keywords or filters.'
          : 'We couldn\'t find any products matching your search.\nTry different keywords or filters.',
      icon: Icons.search_off_rounded,
      onAction: onAction,
      actionButtonText: 'Clear Filters',
    );
  }

  /// Factory constructor for empty chat list
  factory EmptyStateWidget.noChats({
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: 'No Conversations',
      message: 'You don\'t have any conversations yet.\nStart chatting with buyers or sellers!',
      icon: Icons.chat_bubble_outline_rounded,
      onAction: onAction,
      actionButtonText: 'Browse Products',
    );
  }

  /// Factory constructor for empty favorites
  factory EmptyStateWidget.noFavorites({
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: 'No Favorites',
      message: 'You haven\'t added any products to your favorites yet.\nStart exploring and save items you like!',
      icon: Icons.favorite_border_rounded,
      onAction: onAction,
      actionButtonText: 'Browse Products',
    );
  }

  /// Factory constructor for empty seller products
  factory EmptyStateWidget.noSellerProducts({
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: 'No Products Listed',
      message: 'You haven\'t listed any products for sale yet.\nStart selling by adding your first product!',
      icon: Icons.add_shopping_cart_rounded,
      onAction: onAction,
      actionButtonText: 'Add Product',
    );
  }

  /// Factory constructor for empty category
  factory EmptyStateWidget.emptyCategory({
    String? categoryName,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: 'No Products in ${categoryName ?? 'Category'}',
      message: 'There are no products available in this category yet.\nCheck back later or browse other categories.',
      icon: Icons.category_outlined,
      onAction: onAction,
      actionButtonText: 'Browse All',
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
            // Illustration or Icon
            if (illustration != null)
              illustration!
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.primary,
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

            if (onAction != null || onActionPressed != null) const SizedBox(height: AppSpacing.xl),

            // Action Button
            if (onAction != null || onActionPressed != null)
              ModernButton(
                text: actionButtonText ?? actionLabel ?? 'Get Started',
                onPressed: onAction ?? onActionPressed,
                type: ModernButtonType.elevated,
                useGradient: true,
              ),
          ],
        ),
      ),
    );
  }
}
