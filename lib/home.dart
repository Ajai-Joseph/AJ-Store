import 'package:aj_store/Screens/buy.dart';
import 'package:aj_store/Screens/sell.dart';
import 'package:aj_store/login.dart';
import 'package:aj_store/profile.dart';
import 'package:aj_store/selectCategory.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:aj_store/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  final screens = [
    Buy(),
    Sell(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
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
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    ),
                    child: const Icon(Icons.menu, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "AJ Store",
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    // TODO: Implement notifications functionality
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
      drawer: drawer(context),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          elevation: 0,
          height: 65,
          animationDuration: const Duration(milliseconds: 300),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
              label: "Buy",
            ),
            NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront, color: AppColors.primary),
              label: "Sell",
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: screens[currentIndex],
      ),
    );
  }
}

Widget drawer(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.75,
    child: Drawer(
      child: Column(
        children: [
          _ModernDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerMenuItem(
                  icon: Icons.category_outlined,
                  selectedIcon: Icons.category,
                  title: "All Categories",
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(FadeSlidePageRoute(
                        page: SelectCategory(
                              fromWhichPage: "home",
                            )));
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.folder_outlined,
                  selectedIcon: Icons.folder,
                  title: "My Orders",
                  onTap: () {
                    // TODO: Implement My Orders functionality
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  title: "My Account",
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        FadeSlidePageRoute(page: Profile()));
                  },
                ),
                const Divider(height: 32),
                _DrawerMenuItem(
                  icon: Icons.logout_outlined,
                  selectedIcon: Icons.logout,
                  title: "Logout",
                  iconColor: AppColors.error,
                  onTap: () async {
                    final sharedPreference =
                        await SharedPreferences.getInstance();
                    await sharedPreference.clear();
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                          FadeSlidePageRoute(page: const Login()),
                          (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
          _DrawerFooter(),
        ],
      ),
    ),
  );
}

class _ModernDrawerHeader extends StatelessWidget {
  const _ModernDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryVariant,
          ],
        ),
      ),
      child: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("Users")
            .doc(auth.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data();
            final name = userData?['Name'] ?? 'User';
            final email = userData?['Email'] ?? '';
            final image = userData?['Image'];

            return Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: image != null
                              ? DecorationImage(
                                  image: NetworkImage(image),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: image == null ? Colors.white.withValues(alpha: 0.3) : null,
                        ),
                        child: image == null
                            ? const Icon(Icons.person, size: 45, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        name,
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          email,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerMenuItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Developer Contact",
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.email, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  "ajaijoseph363@gmail.com",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "+91 9497308477",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
