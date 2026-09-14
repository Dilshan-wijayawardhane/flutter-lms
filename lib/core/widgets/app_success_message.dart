import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Helper for showing consistent success/info/error snackbars.
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.danger, Icons.error_outline_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.info, Icons.info_outline_rounded);
  }

  static void _show(
      BuildContext context,
      String message,
      Color color,
      IconData icon,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}