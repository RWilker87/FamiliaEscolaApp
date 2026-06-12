import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final String? heroTag;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.heroTag,
  });

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final avatarWidget = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor ?? primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitials(context),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: radius,
                    height: radius,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
          : _buildInitials(context),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: avatarWidget,
        ),
      );
    }
    return avatarWidget;
  }

  Widget _buildInitials(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Center(
      child: Text(
        _initials,
        style: AppTypography.labelLarge.copyWith(
          color: textColor ?? primaryColor,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
