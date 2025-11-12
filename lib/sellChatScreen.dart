import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';

class SellChatScreen extends StatefulWidget {
  final String receiverId;
  final String productId;
  final String productName;
  final String productPrice;
  
  const SellChatScreen({
    Key? key,
    required this.receiverId,
    required this.productId,
    required this.productName,
    required this.productPrice,
  }) : super(key: key);

  @override
  State<SellChatScreen> createState() => _SellChatScreenState();
}

class _SellChatScreenState extends State<SellChatScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  String receiverImage = '';
  String receiverName = '';
  String senderName = '';
  String senderImage = '';
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final senderDoc = await firestore.collection("Users").doc(auth.currentUser!.uid).get();
    if (senderDoc.exists) {
      setState(() {
        senderImage = senderDoc.data()!['Image'] ?? '';
        senderName = senderDoc.data()!['Name'] ?? '';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("Sell Chats")
                  .doc(widget.productId + auth.currentUser!.uid + widget.receiverId)
                  .collection("Messages")
                  .orderBy("Time", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final message = snapshot.data!.docs[index];
                      final isSentByMe = message['SenderId'] == auth.currentUser!.uid;
                      return _buildMessageBubble(message, isSentByMe, index);
                    },
                  );
                } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No messages yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Start the conversation!',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          _buildModernInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection("Users").doc(widget.receiverId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            receiverImage = userData['Image'] ?? '';
            receiverName = userData['Name'] ?? '';
            
            return Row(
              children: [
                Hero(
                  tag: 'avatar_${widget.receiverId}',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surface,
                    backgroundImage: receiverImage.isNotEmpty 
                        ? NetworkImage(receiverImage) 
                        : null,
                    child: receiverImage.isEmpty 
                        ? const Icon(Icons.person, color: AppColors.textSecondary)
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        receiverName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Online',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            child: Image.network(
              'https://via.placeholder.com/40',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  color: AppColors.surface.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 20,
                    color: AppColors.textOnPrimary,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(QueryDocumentSnapshot message, bool isSentByMe, int index) {
    final DateTime dateTime = DateTime.parse(message['Time']);
    final messageText = message['Message'] as String;
    
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSentByMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: receiverImage.isNotEmpty 
                    ? NetworkImage(receiverImage) 
                    : null,
                child: receiverImage.isEmpty 
                    ? const Icon(Icons.person, size: 16, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSentByMe ? AppColors.primaryGradient : null,
                      color: isSentByMe ? null : AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppSpacing.radiusLG),
                        topRight: const Radius.circular(AppSpacing.radiusLG),
                        bottomLeft: Radius.circular(isSentByMe ? AppSpacing.radiusLG : AppSpacing.radiusSM),
                        bottomRight: Radius.circular(isSentByMe ? AppSpacing.radiusSM : AppSpacing.radiusLG),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      messageText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSentByMe ? AppColors.textOnPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      DateFormat.jm().format(dateTime),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSentByMe) ...[
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: senderImage.isNotEmpty 
                    ? NetworkImage(senderImage) 
                    : null,
                child: senderImage.isEmpty 
                    ? const Icon(Icons.person, size: 16, color: AppColors.primary)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernInputBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG + 4),
                ),
                child: TextField(
                  controller: messageController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.textSecondary,
                      size: AppSpacing.iconMD,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
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
                    if (messageController.text.trim().isNotEmpty) {
                      sendMessage();
                    }
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.textOnPrimary,
                      size: AppSpacing.iconMD,
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

  void sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    
    messageController.clear();
    final DateTime date = DateTime.now();

    // Trigger send animation
    _animationController.forward().then((_) => _animationController.reverse());

    try {
      await firestore
          .collection("Sell Chats")
          .doc(widget.productId + auth.currentUser!.uid + widget.receiverId)
          .collection("Messages")
          .add({
        'Message': message,
        'Time': date.toString(),
        'SenderId': auth.currentUser!.uid,
        'ReceiverId': widget.receiverId,
      });

      await firestore
          .collection("Buy Chats")
          .doc(widget.productId + widget.receiverId + auth.currentUser!.uid)
          .collection("Messages")
          .add({
        'Message': message,
        'Time': date.toString(),
        'SenderId': auth.currentUser!.uid,
        'ReceiverId': widget.receiverId,
      });
      
      await firestore
          .collection("Sell Last Message")
          .doc(auth.currentUser!.uid)
          .collection("Messages")
          .doc(widget.productId + widget.receiverId)
          .set({
        'Last Message': message,
        'Name': receiverName,
        'Image': receiverImage,
        'Id': widget.receiverId,
        'Product ID': widget.productId,
        'Product Name': widget.productName,
        'Product Price': widget.productPrice,
      });

      await firestore
          .collection("Buy Last Message")
          .doc(widget.receiverId)
          .collection("Messages")
          .doc(widget.productId + auth.currentUser!.uid)
          .set({
        'Last Message': message,
        'Name': senderName,
        'Image': senderImage,
        'Id': auth.currentUser!.uid,
        'Product ID': widget.productId,
        'Product Name': widget.productName,
        'Product Price': widget.productPrice,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
