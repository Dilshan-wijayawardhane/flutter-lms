import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Circular avatar with network image, fallback initials, and optional badge.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSpacing.avatarMd,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final content = ClipOval(
      child: Container(
        height: size,
        width: size,
        color: AppColors.primarySurface,
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsWidget,
        )
            : _initialsWidget,
      ),
    );

    final bordered = borderWidth > 0
        ? Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? AppColors.primary,
          width: 1.5,
        ),
      ),
      child: content,
    )
        : content;

    if (onTap == null) return bordered;

    return GestureDetector(onTap: onTap, child: bordered);
  }

  Widget get _initialsWidget => Center(
    child: Text(
      _initials,
      style: AppTextStyles.headingSmall.copyWith(
        color: AppColors.primary,
        fontSize: size * 0.36,
      ),
    ),
  );
}