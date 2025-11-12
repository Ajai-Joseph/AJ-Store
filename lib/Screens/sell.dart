import 'package:aj_store/selectCategory.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:aj_store/widgets/empty_state_widget.dart';
import 'package:aj_store/widgets/loading_shimmer.dart';
import 'package:aj_store/widgets/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_spacing.dart';
import '../utils/page_transitions.dart';

class Sell extends StatefulWidget {
  const Sell({super.key});

  @override
  State<Sell> createState() => _SellState();
}

class _SellState extends State<Sell> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("Sellers")
            .doc(_auth.currentUser?.uid)
            .collection("Products")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'No Products Listed',
              message: 'Start selling by adding your first product!',
              actionLabel: 'Add Product',
              onActionPressed: () {
                Navigator.of(context).push(
                  FadeSlidePageRoute(
                    page: SelectCategory(fromWhichPage: "sellProducts"),
                  ),
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh is handled automatically by StreamBuilder
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive column count based on screen width
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                }
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryVariant,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              FadeSlidePageRoute(
                page: SelectCategory(fromWhichPage: "sellProducts"),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Add Product',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
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
    final productId = data['Product ID'] ?? '';

    return Hero(
      tag: 'product_$productId',
      child: ProductCard(
        imageUrl: imageUrl,
        title: title,
        price: price,
        location: location,
        onTap: () {
          Navigator.of(context).push(
            FadeSlidePageRoute(
              page: SellerProductDetails(productId: productId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return const ProductCardShimmer();
          },
        );
      },
    );
  }
}
