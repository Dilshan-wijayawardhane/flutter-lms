import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Header used at the top of auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo) ...[
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(title, style: AppTextStyles.headingLarge),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          )),
        ],
      ],
    );
  }
}