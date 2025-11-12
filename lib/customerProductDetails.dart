import 'package:aj_store/buyChatScreen.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/widgets/modern_button.dart';
import 'package:aj_store/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerProductDetails extends StatefulWidget {
  final String productId;
  
  const CustomerProductDetails({Key? key, required this.productId}) : super(key: key);

  @override
  State<CustomerProductDetails> createState() => _CustomerProductDetailsState();
}

class _CustomerProductDetailsState extends State<CustomerProductDetails> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  double _imageOpacity = 1.0;
  bool _showFullDescription = false;
  
  String? _title, _sellerId, _price, _place, _description, _postedDate, _sellerName, _sellerPhone;
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

  void _showContactDialog(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contact Seller"),
        content: Text("Phone: $phoneNumber"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser!.uid;
    
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          _firestore.collection("Products").doc(widget.productId).get(),
          _firestore.collection("Products").doc(widget.productId).collection("Favorites").doc(userId).get(),
        ]),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data![0].data() == null) {
            return const Center(child: Text("Product not found"));
          }

          final productData = snapshot.data![0].data() as Map<String, dynamic>;
          final favoriteData = snapshot.data![1];
          
          _title = productData['Title'];
          _images = productData['Images'];
          _sellerId = productData['Seller ID'];
          _price = productData['Price'];
          _place = productData['Place'];
          _description = productData['Description'];
          _moreDetailsMap = productData['Map'] ?? {};
          _postedDate = productData['Posted Date'];
          _isFavorite = favoriteData.exists;

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
                    child: _buildContentSection(userId),
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
              
              // Floating Favorite Button
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                right: AppSpacing.md,
                child: _buildFloatingButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  onPressed: _toggleFavorite,
                  color: _isFavorite ? Colors.red : null,
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
                  return GestureDetector(
                    onTap: () {
                      // Could implement full-screen image view here
                    },
                    child: Image.network(
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
                    ),
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

  Widget _buildContentSection(String userId) {
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
            
            // Seller Info Card
            _buildSellerInfoCard(userId),
            
            const SizedBox(height: 100), // Space for bottom action bar (fixed height for action bar clearance)
          ],
        ),
      ),
    );
  }

  Widget _buildSellerInfoCard(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection("Users").doc(_sellerId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final sellerData = snapshot.data!.data() as Map<String, dynamic>;
          _sellerName = sellerData['Name'] ?? 'Unknown';
          _sellerPhone = sellerData['Phone'];
          
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seller Information",
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        _sellerName![0].toUpperCase(),
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sellerName!,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            "Seller",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_sellerPhone != null)
                      IconButton(
                        onPressed: () => _showContactDialog(context, _sellerPhone!),
                        icon: Icon(
                          Icons.phone,
                          color: AppColors.primary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
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
              text: "Chat with Seller",
              onPressed: () {
                Navigator.push(
                  context,
                  FadeSlidePageRoute(
                    page: BuyChatScreen(
                      receiverId: _sellerId!,
                      productId: widget.productId,
                      productName: _title!,
                      productPrice: _price!,
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
              text: "Contact",
              onPressed: () {
                if (_sellerPhone != null) {
                  _showContactDialog(context, _sellerPhone!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Phone number not available"),
                    ),
                  );
                }
              },
              useGradient: true,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() async {
    final userId = _auth.currentUser!.uid;
    final favoriteRef = _firestore
        .collection("Products")
        .doc(widget.productId)
        .collection("Favorites")
        .doc(userId);

    if (_isFavorite) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }
}
