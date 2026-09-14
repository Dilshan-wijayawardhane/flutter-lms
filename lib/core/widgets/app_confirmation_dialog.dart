import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Standard confirmation dialog. Returns true if confirmed.
class AppConfirmationDialog {
  AppConfirmationDialog._();

  static Future<bool> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDestructive = false,
        IconData? icon,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDestructive ? AppColors.danger : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(child: Text(title, style: AppTextStyles.headingSmall)),
          ],
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: cancelLabel,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: isDestructive
                    ? AppButton.danger(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                )
                    : AppButton.primary(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }
}