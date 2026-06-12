import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class AvisoCard extends StatelessWidget {
  final String title;
  final String message;
  final DateTime? date;
  final bool jaLido;
  final String role; // 'gestao' or 'responsavel'
  final int readCount;
  final VoidCallback onTap;

  const AvisoCard({
    super.key,
    required this.title,
    required this.message,
    required this.jaLido,
    required this.role,
    required this.readCount,
    required this.onTap,
    this.date,
  });

  String _fmtData(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat("dd/MM 'às' HH:mm").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isResponsavel = role == 'responsavel';
    final isGestao = role == 'gestao' || role == 'gestor';
    final isUnread = !jaLido && isResponsavel;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary50 : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isUnread
              ? primaryColor.withValues(alpha: 0.3)
              : AppColors.neutral200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        color: isUnread ? primaryColor : AppColors.neutral900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _fmtData(date),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const Spacer(),
                  if (isGestao) ...[
                    const Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$readCount leram',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                  if (isResponsavel && jaLido) ...[
                    const Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Lido',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
