import 'package:aj_store/constants/app_spacing.dart';
import 'package:aj_store/editProductDetails.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/widgets/modern_button.dart';
import 'package:aj_store/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class SellerProductDetails extends StatefulWidget {
  final String productId;
  
  const SellerProductDetails({Key? key, required this.productId}) : super(key: key);

  @override
  State<SellerProductDetails> createState() => _SellerProductDetailsState();
}

class _SellerProductDetailsState extends State<SellerProductDetails> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  int _currentImageIndex = 0;
  double _imageOpacity = 1.0;
  bool _showFullDescription = false;
  
  String? _title, _price, _place, _description, _postedDate;
  Map _moreDetailsMap = {};
  List _images = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Parallax effect for image header
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      setState(() {
        _imageOpacity = (1 - (offset / 300)).clamp(0.3, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection("Products").doc(widget.productId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("Product not found"));
          }

          final productData = snapshot.data!.data() as Map<String, dynamic>;
          
          _title = productData['Title'];
          _images = productData['Images'];
          _price = productData['Price'];
          _place = productData['Place'];
          _description = productData['Description'];
          _moreDetailsMap = productData['Map'] ?? {};
          _postedDate = productData['Posted Date'];

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Image Carousel Header
                  SliverToBoxAdapter(
                    child: _buildImageCarousel(),
                  ),
                  
                  // Content Section
                  SliverToBoxAdapter(
                    child: _buildContentSection(),
                  ),
                ],
              ),
              
              // Floating Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                left: AppSpacing.md,
                child: _buildFloatingButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // Floating Edit Button
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                right: AppSpacing.md + 56,
                child: _buildFloatingButton(
                  icon: Icons.edit,
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(
                        page: EditProductDetails(
                          productId: widget.productId,
                        ),
                      ),
                    );
                  },
                  color: AppColors.primary,
                ),
              ),
              
              // Floating Delete Button
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                right: AppSpacing.md,
                child: _buildFloatingButton(
                  icon: Icons.delete,
                  onPressed: _showDeleteDialog,
                  color: AppColors.error,
                ),
              ),
              
              // Bottom Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomActionBar(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Hero(
      tag: 'product_${widget.productId}',
      child: Container(
        height: 400,
        color: Colors.black,
        child: Stack(
          children: [
            Opacity(
              opacity: _imageOpacity,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    _images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Page Indicators
            if (_images.length > 1)
              Positioned(
                bottom: AppSpacing.md,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentImageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Text(
              "₹ $_price",
              style: AppTextStyles.h1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Title
            Text(
              _title ?? '',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Location and Date
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _place ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _postedDate != null
                      ? DateFormat.yMMMd().format(DateTime.parse(_postedDate!))
                      : '',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            
            // Description Section
            Text(
              "Description",
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            AnimatedCrossFade(
              firstChild: Text(
                _description ?? '',
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                _description ?? '',
                style: AppTextStyles.bodyMedium,
              ),
              crossFadeState: _showFullDescription
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            if ((_description?.length ?? 0) > 100)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showFullDescription = !_showFullDescription;
                  });
                },
                child: Text(
                  _showFullDescription ? "Show less" : "Read more",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            
            // More Details Section
            if (_moreDetailsMap.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Additional Details",
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._moreDetailsMap.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.toString(),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            
            // Buyer Inquiries Section
            _buildBuyerInquiriesSection(),
            
            const SizedBox(height: 100), // Space for bottom action bar (fixed height for action bar clearance)
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerInquiriesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("Sell Last Message")
          .doc(_auth.currentUser!.uid)
          .collection("Messages")
          .where("Product ID", isEqualTo: widget.productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Buyer Inquiries",
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        "No inquiries yet",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Buyer Inquiries (${snapshot.data!.docs.length})",
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['Buyer Name'] ?? 'Buyer',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            data['Last Message'] ?? '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ModernButton(
              text: "Edit Product",
              onPressed: () {
                Navigator.push(
                  context,
                  FadeSlidePageRoute(
                    page: EditProductDetails(
                      productId: widget.productId,
                    ),
                  ),
                );
              },
              type: ModernButtonType.outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ModernButton(
              text: "Delete",
              onPressed: _showDeleteDialog,
              type: ModernButtonType.elevated,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Product?",
            style: AppTextStyles.h3,
          ),
          content: Text(
            "Are you sure you want to delete this product? This action cannot be undone.",
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ModernButton(
              text: "Delete",
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteProduct();
              },
              type: ModernButtonType.elevated,
              width: 100,
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct() async {
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Deleting product...",
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final userId = _auth.currentUser!.uid;
      List buyers = [];

      // Delete images from storage
      for (int i = 0; i < _images.length; i++) {
        try {
          await FirebaseStorage.instance.refFromURL(_images[i]).delete();
        } catch (e) {
          // Continue even if image deletion fails
        }
      }

      // Get buyers list
      final productDoc = await _firestore
          .collection("Products")
          .doc(widget.productId)
          .get();
      
      if (productDoc.exists && productDoc.data()!['Buyers'] != null) {
        buyers = productDoc.data()!['Buyers'];
      }

      // Delete chat messages
      for (int i = 0; i < buyers.length; i++) {
        // Delete buy chat messages
        final buyChatsSnapshot = await _firestore
            .collection("Buy Chats")
            .doc(widget.productId + buyers[i] + userId)
            .collection('Messages')
            .get();
        
        for (var doc in buyChatsSnapshot.docs) {
          await doc.reference.delete();
        }

        // Delete sell chat messages
        final sellChatsSnapshot = await _firestore
            .collection("Sell Chats")
            .doc(widget.productId + userId + buyers[i])
            .collection('Messages')
            .get();
        
        for (var doc in sellChatsSnapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Update last messages
      for (int j = 0; j < buyers.length; j++) {
        try {
          await _firestore
              .collection("Buy Last Message")
              .doc(buyers[j])
              .collection("Messages")
              .doc(widget.productId + userId)
              .update({
            "Last Message": "This ad has been deleted by seller",
          });
        } catch (e) {
          // Continue even if update fails
        }

        try {
          await _firestore
              .collection("Sell Last Message")
              .doc(userId)
              .collection("Messages")
              .doc(widget.productId + buyers[j])
              .delete();
        } catch (e) {
          // Continue even if deletion fails
        }
      }

      // Delete product document
      await _firestore.collection("Products").doc(widget.productId).delete();

      // Delete from seller's products
      await _firestore
          .collection("Sellers")
          .doc(userId)
          .collection("Products")
          .doc(widget.productId)
          .delete();

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      Fluttertoast.showToast(msg: "Product deleted successfully");
      
      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      Fluttertoast.showToast(msg: "Failed to delete product");
    }
  }
}
