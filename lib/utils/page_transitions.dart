import 'package:flutter/material.dart';

/// Custom page route transitions for smooth navigation
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Offset beginOffset;

  FadeSlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0.0, 0.1),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade animation
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            // Slide animation
            final slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Slide from bottom transition (for modals)
class SlideFromBottomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SlideFromBottomPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 250),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        );
}

/// Scale fade transition
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScaleFadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Helper extension for easy navigation with custom transitions
extension NavigationExtensions on BuildContext {
  /// Navigate with fade and slide transition
  Future<T?> pushWithFadeSlide<T>(Widget page) {
    return Navigator.of(this).push<T>(
      FadeSlidePageRoute(page: page),
    );
  }

  /// Navigate with slide from bottom transition
  Future<T?> pushWithSlideFromBottom<T>(Widget page) {
    return Navigator.of(this).push<T>(
      SlideFromBottomPageRoute(page: page),
    );
  }

  /// Navigate with scale fade transition
  Future<T?> pushWithScaleFade<T>(Widget page) {
    return Navigator.of(this).push<T>(
      ScaleFadePageRoute(page: page),
    );
  }

  /// Replace current route with fade and slide transition
  Future<T?> pushReplacementWithFadeSlide<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      FadeSlidePageRoute(page: page),
    );
  }
}
