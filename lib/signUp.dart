import 'dart:io';

import 'package:aj_store/widgets/modern_button.dart';
import 'package:aj_store/widgets/modern_text_field.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  XFile? _image;
  String? _imageUrl;
  bool _isLoading = false;
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _password1Controller.dispose();
    _nameController.dispose();
    _password2Controller.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Stack(
        children: [
          // Gradient top section (40% height)
          Container(
            height: screenHeight * 0.4,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textOnPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  
                  Expanded(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_add_rounded,
                              size: 80,
                              color: AppColors.textOnPrimary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Create Account',
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Sign up to get started',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // White card bottom section (65% height)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: screenHeight * 0.7,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusXXL),
                      topRight: Radius.circular(AppSpacing.radiusXXL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: AppSpacing.elevationLG,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          
                          // Profile photo picker
                          Center(
                            child: GestureDetector(
                              onTap: _showImagePickerBottomSheet,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.background,
                                    backgroundImage: _image == null
                                        ? const AssetImage("assets/pic.png")
                                        : FileImage(File(_image!.path)) as ImageProvider,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSpacing.xs),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: AppSpacing.iconSM,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Name field
                          ModernTextField(
                            controller: _nameController,
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Email field
                          ModernTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Phone field
                          ModernTextField(
                            controller: _phoneController,
                            labelText: 'Mobile Number',
                            hintText: 'Enter your mobile number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (value.length != 10) {
                                return 'Please enter a valid 10-digit number';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Place field
                          ModernTextField(
                            controller: _placeController,
                            labelText: 'Location',
                            hintText: 'Enter your location',
                            prefixIcon: Icons.location_on_outlined,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your location';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Password field
                          ModernTextField(
                            controller: _password1Controller,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _obscurePassword1
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscurePassword1 = !_obscurePassword1;
                              });
                            },
                            obscureText: _obscurePassword1,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Confirm password field
                          ModernTextField(
                            controller: _password2Controller,
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _obscurePassword2
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscurePassword2 = !_obscurePassword2;
                              });
                            },
                            obscureText: _obscurePassword2,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _password1Controller.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          
                          // Sign up button
                          ModernButton(
                            text: 'Sign Up',
                            onPressed: _isLoading ? null : _handleSignUp,
                            type: ModernButtonType.elevated,
                            useGradient: true,
                            isLoading: _isLoading,
                            width: double.infinity,
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerBottomSheet() {
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
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
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to pick image",
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> _handleSignUp() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if image is selected
    if (_image == null) {
      Fluttertoast.showToast(
        msg: "Please upload your photo",
        backgroundColor: AppColors.warning,
      );
      return;
    }

    // Check if passwords match
    if (_password1Controller.text != _password2Controller.text) {
      Fluttertoast.showToast(
        msg: "Passwords do not match",
        backgroundColor: AppColors.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user account
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _password1Controller.text,
      );

      // Upload profile photo
      final Reference reference = _firebaseStorage
          .ref()
          .child("Profile Photos")
          .child(_auth.currentUser!.uid);

      final UploadTask uploadTask = reference.putFile(File(_image!.path));
      final TaskSnapshot taskSnapshot = await uploadTask;
      _imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Save user data to Firestore
      await _firebaseFirestore
          .collection("Users")
          .doc(_auth.currentUser!.uid)
          .set({
        'Name': _nameController.text.trim(),
        'Email': _emailController.text.trim(),
        'Image': _imageUrl,
        'Password': _password1Controller.text,
        'Id': _auth.currentUser!.uid,
        'Phone': _phoneController.text.trim(),
        'Place': _placeController.text.trim(),
      });

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Registration Successful",
        backgroundColor: AppColors.success,
      );

      // Navigate back to login
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address";
          break;
        case 'weak-password':
          errorMessage = "Password is too weak";
          break;
        default:
          errorMessage = "Registration failed. Please try again";
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: AppColors.error,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again",
        backgroundColor: AppColors.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
