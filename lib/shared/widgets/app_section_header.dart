import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: primaryColor,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.neutral900,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
