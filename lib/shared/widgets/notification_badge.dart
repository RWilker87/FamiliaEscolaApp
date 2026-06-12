import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class NotificationBadge extends StatefulWidget {
  final int count;
  final Widget? child;
  final double size;

  const NotificationBadge({
    super.key,
    required this.count,
    this.child,
    this.size = 18,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.4)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.4, end: 0.9)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.9, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
    ]).animate(_controller);

    if (widget.count > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count && widget.count > 0) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) {
      return widget.child ?? const SizedBox.shrink();
    }

    final badgeWidget = ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        constraints: BoxConstraints(
          minWidth: widget.size,
          minHeight: widget.size,
        ),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Center(
          child: Text(
            widget.count > 99 ? '99+' : '${widget.count}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.white,
              fontSize: widget.size * 0.55,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    if (widget.child == null) {
      return badgeWidget;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child!,
        Positioned(
          top: -2,
          right: -4,
          child: badgeWidget,
        ),
      ],
    );
  }
}
