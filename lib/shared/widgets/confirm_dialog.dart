import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.cancelLabel = 'Cancelar',
    this.confirmLabel = 'Confirmar',
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String cancelLabel = 'Cancelar',
    String confirmLabel = 'Confirmar',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(
        title,
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.neutral900,
        ),
      ),
      content: Text(
        message,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.neutral600,
        ),
      ),
      actionsPadding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  side: const BorderSide(color: AppColors.neutral300),
                  foregroundColor: AppColors.neutral600,
                ),
                child: Text(cancelLabel),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                  onConfirm();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  backgroundColor: isDestructive ? AppColors.error : primaryColor,
                  foregroundColor: AppColors.white,
                ),
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
