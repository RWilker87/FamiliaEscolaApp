import 'package:flutter/material.dart';

class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayStep;
  final Duration duration;
  final double offset;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    required this.index,
    this.delayStep = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 350),
    this.offset = 30.0,
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, widget.offset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    Future.delayed(widget.delayStep * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
