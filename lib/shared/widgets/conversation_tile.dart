import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'app_avatar.dart';
import 'notification_badge.dart';

class ConversationTile extends StatelessWidget {
  final String title;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ConversationTile({
    super.key,
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.onTap,
    this.avatarUrl,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isUnread = unreadCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary50 : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isUnread
              ? primaryColor.withValues(alpha: 0.2)
              : AppColors.neutral200,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.sm,
        ),
        leading: AppAvatar(
          name: title,
          imageUrl: avatarUrl,
          radius: 24,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              time,
              style: AppTypography.caption.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            lastMessage.isNotEmpty ? lastMessage : 'Nenhuma mensagem ainda',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: isUnread ? primaryColor : AppColors.neutral500,
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUnread) ...[
              NotificationBadge(count: unreadCount),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (onDelete != null)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.neutral400,
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Deletar conversa',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
