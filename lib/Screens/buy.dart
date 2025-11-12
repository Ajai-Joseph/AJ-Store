import 'package:aj_store/customerProductDetails.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:aj_store/widgets/empty_state_widget.dart';
import 'package:aj_store/widgets/loading_shimmer.dart';
import 'package:aj_store/widgets/modern_text_field.dart';
import 'package:aj_store/widgets/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_spacing.dart';
import '../utils/page_transitions.dart';

class Buy extends StatefulWidget {
  const Buy({super.key});

  @override
  State<Buy> createState() => _BuyState();
}

class _BuyState extends State<Buy> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isGridView = true;
  String? _selectedCategory;
  String _searchQuery = '';
  
  final List<String> _categories = [
    'All',
    'Electronics',
    'Home',
    'Sports',
    'Books',
    'Toys',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Modern search header
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar with view toggle
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ModernTextField(
                          controller: _searchController,
                          hintText: 'Search products...',
                          prefixIcon: Icons.search,
                          suffixIcon: _searchQuery.isNotEmpty ? Icons.clear : null,
                          onSuffixIconTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // View toggle button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryVariant,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isGridView = !_isGridView;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                                color: AppColors.textOnPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Category chips
                SizedBox(
                  height: 56,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category || 
                                       (_selectedCategory == null && category == 'All');
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category == 'All' ? null : category;
                            });
                          },
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.primary,
                          side: BorderSide(
                            color: isSelected 
                                ? AppColors.primary 
                                : AppColors.divider,
                            width: 1.5,
                          ),
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          checkmarkColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Product grid/list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("Products").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No Products Available',
                    message: 'There are no products listed at the moment. Check back later!',
                  );
                }
                
                // Filter products
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['Title'] ?? '').toString().toLowerCase();
                  final category = data['Category'] ?? '';
                  
                  // Apply search filter
                  if (_searchQuery.isNotEmpty && !title.contains(_searchQuery)) {
                    return false;
                  }
                  
                  // Apply category filter
                  if (_selectedCategory != null && category != _selectedCategory) {
                    return false;
                  }
                  
                  return true;
                }).toList();
                
                if (filteredDocs.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'No Results Found',
                    message: 'Try adjusting your search or filters',
                    actionLabel: 'Clear Filters',
                    onActionPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedCategory = null;
                      });
                    },
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    // Refresh is handled automatically by StreamBuilder
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppColors.primary,
                  child: _isGridView
                      ? _buildGridView(filteredDocs)
                      : _buildListView(filteredDocs),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<QueryDocumentSnapshot> docs) {
    return LayoutBuilder(
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
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildProductCard(docs[index]);
          },
        );
      },
    );
  }

  Widget _buildListView(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: SizedBox(
            height: 120,
            child: _buildProductCard(docs[index]),
          ),
        );
      },
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
    
    return Hero(
      tag: 'product_$productId',
      child: ProductCard(
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
