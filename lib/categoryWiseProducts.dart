import 'package:aj_store/customerProductDetails.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:aj_store/widgets/empty_state_widget.dart';
import 'package:aj_store/widgets/loading_shimmer.dart';
import 'package:aj_store/widgets/product_card.dart';
import 'package:aj_store/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'constants/app_spacing.dart';

class CategoryWiseProducts extends StatefulWidget {
  final String categoryName;
  
  const CategoryWiseProducts({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryWiseProducts> createState() => _CategoryWiseProductsState();
}

class _CategoryWiseProductsState extends State<CategoryWiseProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(
          widget.categoryName,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textOnPrimary,
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("Products")
            .where('Category', isEqualTo: widget.categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.category_outlined,
              title: 'No Products in ${widget.categoryName}',
              message: 'There are no products in this category yet. Check back later!',
              actionLabel: 'Go Back',
              onActionPressed: () {
                Navigator.of(context).pop();
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh is handled automatically by StreamBuilder
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
                return _buildProductCard(snapshot.data!.docs[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final images = data['Images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.first.toString() : '';
    final title = data['Title'] ?? 'No Title';
    final price = '₹ ${data['Price'] ?? '0'}';
    final location = data['Place'] ?? 'Unknown';
    final sellerId = data['Seller ID'] ?? '';
    final productId = data['Product ID'] ?? '';

    return ProductCard(
      imageUrl: imageUrl,
      title: title,
      price: price,
      location: location,
      onTap: () {
        if (sellerId == _auth.currentUser?.uid) {
          Navigator.of(context).push(
            FadeSlidePageRoute(
              page: SellerProductDetails(productId: productId),
            ),
          );
        } else {
          Navigator.of(context).push(
            FadeSlidePageRoute(
              page: CustomerProductDetails(productId: productId),
            ),
          );
        }
      },
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ProductCardShimmer();
      },
    );
  }
}
