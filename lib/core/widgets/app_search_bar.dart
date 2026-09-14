import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable search field with optional filter button.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.md,
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: const SizedBox(
                height: 48,
                width: 48,
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}