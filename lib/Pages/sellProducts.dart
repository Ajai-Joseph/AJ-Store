import 'package:aj_store/selectCategory.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:aj_store/editProductDetails.dart';
import 'package:aj_store/widgets/product_card.dart';
import 'package:aj_store/widgets/loading_shimmer.dart';
import 'package:aj_store/widgets/empty_state_widget.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellProducts extends StatefulWidget {
  const SellProducts({super.key});

  @override
  State<SellProducts> createState() => _SellProductsState();
}

class _SellProductsState extends State<SellProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showProductActions(BuildContext context, String productId, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  title,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: Text('Edit Product', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProductDetails(productId: productId),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: Text('Delete Product', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, productId);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          title: Text('Delete Product', style: AppTextStyles.h3),
          content: Text(
            'Are you sure you want to delete this product? This action cannot be undone.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteProduct(productId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      // Delete from seller's products
      await _firestore
          .collection("Sellers")
          .doc(_auth.currentUser!.uid)
          .collection("Products")
          .doc(productId)
          .delete();

      // Delete from main products collection
      await _firestore.collection("Products").doc(productId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product deleted successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("Sellers")
              .doc(_auth.currentUser!.uid)
              .collection("Products")
              .snapshots(),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const ProductCardShimmer(),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                message: 'Unable to load your products. Please try again.',
                actionLabel: 'Retry',
                onActionPressed: () {
                  setState(() {});
                },
              );
            }

            // No data or empty
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.inventory_2_outlined,
                title: 'No Products Listed',
                message: 'Start selling by adding your first product!',
                actionLabel: 'Add Product',
                onActionPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectCategory(fromWhichPage: "sellProducts"),
                    ),
                  );
                },
              );
            }

            // Display products
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final product = snapshot.data!.docs[index];
                  final images = product['Images'] as List;
                  final productId = product['Product ID'] as String;
                  final title = product['Title'] as String;

                  return Stack(
                    children: [
                      ProductCard(
                        imageUrl: images.isNotEmpty ? images.first : '',
                        title: title,
                        price: '₹ ${product['Price']}',
                        location: product['Place'] ?? '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SellerProductDetails(productId: productId),
                            ),
                          );
                        },
                      ),
                      // Quick action button
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showProductActions(context, productId, title),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.more_vert,
                                color: AppColors.textPrimary,
                                size: AppSpacing.iconSM,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        // Floating action button
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SelectCategory(fromWhichPage: "sellProducts"),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.add,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
