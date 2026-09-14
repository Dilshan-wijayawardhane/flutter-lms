import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Consistent surface card with optional tap, padding, and border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showBorder;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusMd;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.border)
            : null,
        boxShadow: elevation > 0
            ? [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: elevation * 4,
            offset: Offset(0, elevation),
          ),
        ]
            : null,
      ),
      child: child,
    );

    if (onTap == null) {
      return margin == null ? content : Padding(padding: margin!, child: content);
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      ),
    );
  }
}