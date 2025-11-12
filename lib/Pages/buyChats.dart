import 'package:aj_store/buyChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:aj_store/widgets/empty_state_widget.dart';

class BuyChats extends StatefulWidget {
  const BuyChats({Key? key}) : super(key: key);

  @override
  State<BuyChats> createState() => _BuyChatsState();
}

class _BuyChatsState extends State<BuyChats> with SingleTickerProviderStateMixin {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = auth.currentUser!.uid;
    
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseFirestore
          .collection("Buy Last Message")
          .doc(userId)
          .collection("Messages")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.chat_bubble_outline,
            title: 'No conversations yet',
            message: 'Start chatting with sellers about products you\'re interested in',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chat = snapshot.data!.docs[index];
            return _buildModernChatItem(context, chat, userId, index);
          },
        );
      },
    );
  }

  Widget _buildModernChatItem(
    BuildContext context,
    QueryDocumentSnapshot chat,
    String userId,
    int index,
  ) {
    final isDeleted = chat['Last Message'] == "This ad has been deleted by seller";
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Slidable(
        key: ValueKey(chat.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) async {
                await _deleteChat(userId, chat);
              },
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppSpacing.radiusMD),
                bottomRight: Radius.circular(AppSpacing.radiusMD),
              ),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDeleted
                  ? null
                  : () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              BuyChatScreen(
                            receiverId: chat['Id'],
                            productId: chat['Product ID'],
                            productName: chat['Product Name'],
                            productPrice: chat['Product Price'],
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // User Avatar
                    Hero(
                      tag: 'avatar_${chat['Id']}',
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            backgroundImage: chat['Image'] != null && chat['Image'].isNotEmpty
                                ? NetworkImage(chat['Image'])
                                : null,
                            child: chat['Image'] == null || chat['Image'].isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 28,
                                  )
                                : null,
                          ),
                          if (!isDeleted)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    
                    // Chat Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chat['Name'] ?? 'Unknown',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            chat['Last Message'] ?? '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDeleted ? AppColors.error : AppColors.textSecondary,
                              fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  chat['Product Name'] ?? '',
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: AppSpacing.sm),
                    
                    // Product Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: AppColors.textHint,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          chat['Product Price'] ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteChat(String userId, QueryDocumentSnapshot chat) async {
    try {
      await firebaseFirestore
          .collection("Buy Last Message")
          .doc(userId)
          .collection("Messages")
          .doc(chat['Product ID'] + chat['Id'])
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Conversation deleted'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
          ),
        );
      }
    }
  }
}
