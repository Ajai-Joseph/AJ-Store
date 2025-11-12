import 'package:flutter/material.dart';

/// A wrapper widget that adds shake animation to its child when an error occurs
/// Useful for form validation errors
class ShakeErrorWidget extends StatefulWidget {
  final Widget child;
  final bool hasError;
  final Duration duration;
  final double offset;

  const ShakeErrorWidget({
    super.key,
    required this.child,
    required this.hasError,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 10.0,
  });

  @override
  State<ShakeErrorWidget> createState() => ShakeErrorWidgetState();
}

class ShakeErrorWidgetState extends State<ShakeErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _previousErrorState = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: widget.offset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.offset, end: -widget.offset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -widget.offset, end: widget.offset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: widget.offset, end: -widget.offset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -widget.offset, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShakeErrorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger shake animation when error state changes from false to true
    if (widget.hasError && !_previousErrorState) {
      shake();
    }
    
    _previousErrorState = widget.hasError;
  }

  /// Public method to manually trigger shake animation
  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
