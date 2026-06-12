import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';

class AppLoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const AppLoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.sm)),
  });

  // A standalone block skeleton
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  // Pre-configured list item skeleton loader
  static Widget list({int itemCount = 4, bool showAvatar = true}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showAvatar) ...[
            const AppLoadingSkeleton(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLoadingSkeleton(width: 120, height: 16),
                const SizedBox(height: AppSpacing.xs),
                const AppLoadingSkeleton(width: double.infinity, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pre-configured card skeleton loader
  static Widget cards({int itemCount = 3}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.neutral200),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppLoadingSkeleton(width: 140, height: 18),
                AppLoadingSkeleton(width: 60, height: 16),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            AppLoadingSkeleton(width: double.infinity, height: 14),
            SizedBox(height: AppSpacing.sm),
            AppLoadingSkeleton(width: 200, height: 14),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                AppLoadingSkeleton(
                  width: 16,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
                ),
                SizedBox(width: AppSpacing.xs),
                AppLoadingSkeleton(width: 80, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
