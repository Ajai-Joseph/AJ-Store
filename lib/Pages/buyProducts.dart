import 'package:aj_store/customerProductDetails.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:aj_store/widgets/product_card.dart';
import 'package:aj_store/widgets/loading_shimmer.dart';
import 'package:aj_store/widgets/empty_state_widget.dart';
import 'package:aj_store/widgets/modern_text_field.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyProducts extends StatefulWidget {
  const BuyProducts({super.key});

  @override
  State<BuyProducts> createState() => _BuyProductsState();
}

class _BuyProductsState extends State<BuyProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _sortBy = 'recent'; // recent, price_low, price_high
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
      _isSearching = value.isNotEmpty;
    });
  }

  void _showSortOptions() {
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
                  'Sort By',
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption('Recent First', 'recent', Icons.access_time),
              _buildSortOption('Price: Low to High', 'price_low', Icons.arrow_upward),
              _buildSortOption('Price: High to Low', 'price_high', Icons.arrow_downward),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  List<QueryDocumentSnapshot> _filterAndSortProducts(List<QueryDocumentSnapshot> products) {
    // Filter by search query
    var filtered = products.where((doc) {
      if (!_isSearching) return true;
      final title = (doc['Title'] as String).toLowerCase();
      return title.contains(_searchQuery);
    }).toList();

    // Sort products
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'price_low':
          final priceA = double.tryParse(a['Price'].toString()) ?? 0;
          final priceB = double.tryParse(b['Price'].toString()) ?? 0;
          return priceA.compareTo(priceB);
        case 'price_high':
          final priceA = double.tryParse(a['Price'].toString()) ?? 0;
          final priceB = double.tryParse(b['Price'].toString()) ?? 0;
          return priceB.compareTo(priceA);
        case 'recent':
        default:
          // Assuming newer products are added later in the list
          return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ModernTextField(
                  controller: _searchController,
                  hintText: 'Search products...',
                  prefixIcon: Icons.search,
                  onChanged: _onSearchChanged,
                  suffixIcon: _isSearching ? Icons.clear : null,
                  onSuffixIconTap: _isSearching
                      ? () {
                          _searchController.clear();
                          _onSearchChanged('');
                        }
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                child: InkWell(
                  onTap: _showSortOptions,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: const Icon(
                      Icons.sort,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Product grid
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection("Products").snapshots(),
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
                  message: 'Unable to load products. Please try again.',
                  actionLabel: 'Retry',
                  onActionPressed: () {
                    setState(() {});
                  },
                );
              }

              // No data
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.shopping_bag_outlined,
                  title: 'No Products Yet',
                  message: 'Be the first to list a product!',
                );
              }

              // Filter and sort products
              final filteredProducts = _filterAndSortProducts(snapshot.data!.docs);

              // Empty search results
              if (filteredProducts.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.search_off,
                  title: 'No Results Found',
                  message: 'Try adjusting your search terms',
                  actionLabel: 'Clear Search',
                  onActionPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
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
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final images = product['Images'] as List;
                    final sellerId = product['Seller ID'] as String;
                    final productId = product['Product ID'] as String;
                    final isOwnProduct = sellerId == _auth.currentUser?.uid;

                    return ProductCard(
                      imageUrl: images.isNotEmpty ? images.first : '',
                      title: product['Title'] ?? '',
                      price: '₹ ${product['Price']}',
                      location: product['Place'] ?? '',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => isOwnProduct
                                ? SellerProductDetails(productId: productId)
                                : CustomerProductDetails(productId: productId),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
