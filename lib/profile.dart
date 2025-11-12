import 'package:aj_store/login.dart';
import 'package:aj_store/updateProfile.dart';
import 'package:aj_store/widgets/modern_button.dart';
import 'package:aj_store/widgets/product_card.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:aj_store/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _name, _email, _image, _phone, _place;
  List<Map<String, dynamic>> _userProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadUserProducts();
  }

  Future<void> _loadUserProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final productsSnapshot = await FirebaseFirestore.instance
          .collection("Products")
          .where("Seller ID", isEqualTo: _auth.currentUser!.uid)
          .limit(6)
          .get();

      setState(() {
        _userProducts = productsSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("Users")
            .doc(_auth.currentUser!.uid)
            .get()
            .then((value) {
          _name = value.data()!['Name'];
          _email = value.data()!['Email'];
          _image = value.data()!['Image'];
          _phone = value.data()!['Phone'];
          _place = value.data()!['Place'];
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Gradient header with avatar and user info
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // App bar with actions
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textOnPrimary,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Text(
                                'Profile',
                                style: AppTextStyles.h2White,
                              ),
                              PopupMenuButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: AppColors.textOnPrimary,
                                ),
                                onSelected: (item) => _handleMenuSelection(context, item),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 0,
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: AppSpacing.iconSM),
                                        SizedBox(width: AppSpacing.sm),
                                        Text("Edit Profile"),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: AppSpacing.iconSM, color: AppColors.error),
                                        SizedBox(width: AppSpacing.sm),
                                        Text("Delete Account", style: TextStyle(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Avatar and user info
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xl,
                          ),
                          child: Column(
                            children: [
                              // Avatar with edit icon
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.textOnPrimary,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: AppSpacing.avatarXL / 2,
                                      backgroundColor: AppColors.surface,
                                      backgroundImage: _image != null && _image!.isNotEmpty
                                          ? NetworkImage(_image!)
                                          : null,
                                      child: _image == null || _image!.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              size: AppSpacing.iconXL,
                                              color: AppColors.textSecondary,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _navigateToEditProfile(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.textOnPrimary,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: AppSpacing.iconSM,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              // Name
                              Text(
                                _name ?? 'User',
                                style: AppTextStyles.h2White,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              // Email
                              Text(
                                _email ?? '',
                                style: AppTextStyles.bodyMediumWhite.copyWith(
                                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Info cards section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal information card
                      _buildInfoCard(
                        title: 'Personal Information',
                        items: [
                          _InfoItem(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: _phone ?? 'Not provided',
                          ),
                          _InfoItem(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: _place ?? 'Not provided',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Statistics card
                      _buildStatsCard(),
                      const SizedBox(height: AppSpacing.md),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ModernButton(
                              text: 'Edit Profile',
                              icon: Icons.edit_outlined,
                              type: ModernButtonType.outlined,
                              onPressed: () => _navigateToEditProfile(context),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ModernButton(
                              text: 'Settings',
                              icon: Icons.settings_outlined,
                              type: ModernButtonType.text,
                              onPressed: () {
                                // Settings functionality can be added later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Settings coming soon'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Listed products section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Products',
                            style: AppTextStyles.h3,
                          ),
                          if (_userProducts.length >= 6)
                            TextButton(
                              onPressed: () {
                                // Navigate to all products
                              },
                              child: const Text('View All'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              // Products grid
              _isLoadingProducts
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : _userProducts.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: AppSpacing.iconXL * 2,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No products listed yet',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = _userProducts[index];
                                final images = product['Images'] as List<dynamic>?;
                                final imageUrl = images != null && images.isNotEmpty
                                    ? images[0].toString()
                                    : '';

                                return ProductCard(
                                  imageUrl: imageUrl,
                                  title: product['Product Name'] ?? '',
                                  price: '₹${product['Price'] ?? '0'}',
                                  location: product['Place'] ?? '',
                                  onTap: () {
                                    // Navigate to product details
                                  },
                                );
                              },
                              childCount: _userProducts.length,
                            ),
                          ),
                        ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xl),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.elevationSM * 2,
            offset: const Offset(0, AppSpacing.elevationSM),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLargeBold,
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                      ),
                      child: Icon(
                        item.icon,
                        size: AppSpacing.iconMD,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.value,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.elevationSM * 2,
            offset: const Offset(0, AppSpacing.elevationSM),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.inventory_2_outlined,
              label: 'Listed',
              value: _userProducts.length.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.visibility_outlined,
              label: 'Views',
              value: '0',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.favorite_outline,
              label: 'Favorites',
              value: '0',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: AppSpacing.iconLG,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      FadeSlidePageRoute(page: const UpdateProfile()),
    ).then((_) {
      // Refresh profile data when returning
      setState(() {});
    });
  }

  void _handleMenuSelection(BuildContext context, int item) {
    switch (item) {
      case 0:
        _navigateToEditProfile(context);
        break;
      case 1:
        _showDeleteAccountDialog(context);
        break;
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          title: const Text("Delete Account?"),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
          ),
          actions: [
            ModernButton(
              text: "Cancel",
              type: ModernButtonType.text,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ModernButton(
              text: "Delete",
              type: ModernButtonType.elevated,
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(_auth.currentUser!.uid)
                      .delete();

                  await FirebaseStorage.instance
                      .ref()
                      .child("Profile Photos")
                      .child(_auth.currentUser!.uid)
                      .delete();

                  await _auth.currentUser!.delete();

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      FadeSlidePageRoute(page: const Login()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete account: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
