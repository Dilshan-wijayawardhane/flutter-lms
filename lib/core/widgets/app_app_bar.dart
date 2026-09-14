import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Standard app bar with optional back button, actions, and avatar slot.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.onBackTap,
    this.backgroundColor,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    AppSpacing.appBarHeight + (subtitle != null ? 20 : 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false,
      leading: leading ??
          (showBackButton
              ? IconButton(
            onPressed: onBackTap ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          )
              : null),
      title: subtitle == null
          ? Text(title, style: AppTextStyles.headingSmall)
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          const SizedBox(height: 2),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}