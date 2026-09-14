import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Standard primary button. Variants: primary (filled), secondary (outlined),
/// text. Includes built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isDisabled = false,
  });

  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    bool isDisabled = false,
  }) {
    return AppButton._(
      label: label,
      onPressed: onPressed,
      variant: _ButtonVariant.primary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      isDisabled: isDisabled,
    );
  }

  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    bool isDisabled = false,
  }) {
    return AppButton._(
      label: label,
      onPressed: onPressed,
      variant: _ButtonVariant.secondary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      isDisabled: isDisabled,
    );
  }

  factory AppButton.text({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    bool isDisabled = false,
  }) {
    return AppButton._(
      label: label,
      onPressed: onPressed,
      variant: _ButtonVariant.text,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      isDisabled: isDisabled,
    );
  }

  factory AppButton.danger({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    bool isDisabled = false,
  }) {
    return AppButton._(
      label: label,
      onPressed: onPressed,
      variant: _ButtonVariant.danger,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      isDisabled: isDisabled,
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final _ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    final child = isLoading
        ? const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    )
        : _buildContent();

    Widget button;
    switch (variant) {
      case _ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;
      case _ButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;
      case _ButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;
      case _ButtonVariant.danger:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: child,
        );
        break;
    }

    if (!isFullWidth) return button;

    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildContent() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppSpacing.iconMd),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.button.copyWith(
          color: variant == _ButtonVariant.secondary ||
              variant == _ButtonVariant.text
              ? null
              : Colors.white,
        )),
      ],
    );
  }
}

enum _ButtonVariant { primary, secondary, text, danger }