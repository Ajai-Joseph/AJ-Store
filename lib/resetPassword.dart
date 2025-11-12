import 'package:aj_store/login.dart';
import 'package:aj_store/widgets/modern_button.dart';
import 'package:aj_store/widgets/modern_text_field.dart';
import 'package:aj_store/theme/app_colors.dart';
import 'package:aj_store/theme/app_text_styles.dart';
import 'package:aj_store/constants/app_spacing.dart';
import 'package:aj_store/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _emailError;
  
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          
          SafeArea(
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: AppSpacing.elevationLG,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock_reset,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: AppSpacing.lg),
                                  
                                  // Title
                                  Text(
                                    'Reset Password',
                                    style: AppTextStyles.h2,
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: AppSpacing.sm),
                                  
                                  // Description
                                  Text(
                                    'Enter your email address and we\'ll send you a link to reset your password.',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: AppSpacing.xl),
                                  
                                  // Email field
                                  ModernTextField(
                                    controller: _emailController,
                                    labelText: 'Email',
                                    hintText: 'Enter your email',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    errorText: _emailError,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    onChanged: (_) {
                                      if (_emailError != null) {
                                        setState(() => _emailError = null);
                                      }
                                    },
                                  ),
                                  
                                  const SizedBox(height: AppSpacing.xl),
                                  
                                  // Send request button
                                  ModernButton(
                                    text: 'Send Reset Link',
                                    onPressed: _isLoading ? null : _handleResetPassword,
                                    type: ModernButtonType.elevated,
                                    useGradient: true,
                                    isLoading: _isLoading,
                                    width: double.infinity,
                                  ),
                                  
                                  const SizedBox(height: AppSpacing.md),
                                  
                                  // Back to login
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Back to Login',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    // Clear previous errors
    setState(() => _emailError = null);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Clear shared preferences and sign out
      final sharedPreference = await SharedPreferences.getInstance();
      await sharedPreference.clear();
      await _auth.signOut();

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Password reset email sent successfully",
        backgroundColor: AppColors.success,
      );

      // Navigate back to login
      Navigator.of(context).pushAndRemoveUntil(
        FadeSlidePageRoute(page: const Login()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to send reset email";

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found with this email";
          setState(() => _emailError = errorMessage);
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address";
          setState(() => _emailError = errorMessage);
          break;
        default:
          errorMessage = "Failed to send reset email. Please try again";
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
