import 'package:aj_store/home.dart';
import 'package:aj_store/main.dart';
import 'package:aj_store/resetPassword.dart';
import 'package:aj_store/signUp.dart';
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

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  
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
    _passwordController.dispose();
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
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_rounded,
                        size: 80,
                        color: AppColors.textOnPrimary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sign in to continue',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // White card bottom section (60% height)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: screenHeight * 0.65,
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
                          
                          // Email field
                          ModernTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
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
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Password field
                          ModernTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            errorText: _passwordError,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              if (_passwordError != null) {
                                setState(() => _passwordError = null);
                              }
                            },
                          ),
                          
                          // Forgot password button
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  FadeSlidePageRoute(
                                    page: ResetPassword(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Login button
                          ModernButton(
                            text: 'Login',
                            onPressed: _isLoading ? null : _handleLogin,
                            type: ModernButtonType.elevated,
                            useGradient: true,
                            isLoading: _isLoading,
                            width: double.infinity,
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          
                          // Sign up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    FadeSlidePageRoute(
                                      page: SignUp(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      final sharedPreference = await SharedPreferences.getInstance();
      await sharedPreference.setBool(saveKey, true);
      
      if (!mounted) return;
      
      Fluttertoast.showToast(
        msg: "Login Successful",
        backgroundColor: AppColors.success,
      );
      
      Navigator.of(context).pushReplacement(
        FadeSlidePageRoute(page: Home()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login Failed";
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email";
          setState(() => _emailError = errorMessage);
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password";
          setState(() => _passwordError = errorMessage);
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address";
          setState(() => _emailError = errorMessage);
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled";
          break;
        default:
          errorMessage = "Login failed. Please try again";
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
