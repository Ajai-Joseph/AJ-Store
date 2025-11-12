import 'dart:io';

import 'package:aj_store/profile.dart';
import 'package:aj_store/resetPassword.dart';
import 'package:aj_store/widgets/modern_button.dart';
import 'package:aj_store/widgets/modern_text_field.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:aj_store/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  String? _name, _phone, _place;
  String? _image;
  XFile? _selectedImage;
  String? _imgUrl;
  bool _hasImageChanged = false;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (item) => _handleMenuSelection(context, item),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: AppSpacing.iconSM),
                    SizedBox(width: AppSpacing.sm),
                    Text("Change Password"),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: FutureBuilder(
        future: _firestore
            .collection("Users")
            .doc(_auth.currentUser!.uid)
            .get()
            .then((value) {
          _name = value.data()!['Name'];
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

          // Initialize controllers with fetched data
          if (_nameController.text.isEmpty && _name != null) {
            _nameController.text = _name!;
            _phoneController.text = _phone!;
            _placeController.text = _place!;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    // Avatar upload section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: AppSpacing.avatarXL / 2,
                              backgroundColor: AppColors.surface,
                              backgroundImage: _hasImageChanged && _selectedImage != null
                                  ? FileImage(File(_selectedImage!.path))
                                  : (_image != null && _image!.isNotEmpty
                                      ? NetworkImage(_image!)
                                      : null) as ImageProvider?,
                              child: (_image == null || _image!.isEmpty) && !_hasImageChanged
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
                              onTap: _showImageSourceBottomSheet,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: AppSpacing.iconMD,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: Text(
                        'Tap to change photo',
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Form fields
                    Text(
                      'Personal Information',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ModernTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ModernTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your phone number";
                        }
                        if (value.length != 10) {
                          return "Please enter a valid 10-digit phone number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ModernTextField(
                      controller: _placeController,
                      labelText: 'Location',
                      prefixIcon: Icons.location_on_outlined,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your location";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Email display (read-only)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: AppColors.textSecondary,
                            size: AppSpacing.iconMD,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _auth.currentUser?.email ?? '',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.lock_outline,
                            color: AppColors.textHint,
                            size: AppSpacing.iconSM,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Action buttons
                    ModernButton(
                      text: 'Save Changes',
                      useGradient: true,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleSaveProfile,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ModernButton(
                      text: 'Cancel',
                      type: ModernButtonType.outlined,
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Choose Profile Photo',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppSpacing.iconXL,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImage = pickedImage;
          _hasImageChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if changed
      if (_hasImageChanged && _selectedImage != null) {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child("Profile Photos")
            .child(_auth.currentUser!.uid);
        
        final UploadTask uploadTask = storageRef.putFile(File(_selectedImage!.path));
        final TaskSnapshot taskSnapshot = await uploadTask;
        _imgUrl = await taskSnapshot.ref.getDownloadURL();
      } else {
        _imgUrl = _image;
      }

      // Update user data
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
        'Name': _nameController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'Image': _imgUrl,
        'Place': _placeController.text.trim(),
      });

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          backgroundColor: AppColors.success,
        );
        
        Navigator.of(context).pushReplacement(
          FadeSlidePageRoute(page: const Profile()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleMenuSelection(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.of(context).push(
          FadeSlidePageRoute(page: const ResetPassword()),
        );
        break;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    super.dispose();
  }
}
