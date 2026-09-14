import 'package:flutter/material.dart';

import 'app_button.dart';

/// Small retry button used in inline error states (list footers, cards).
class AppRetryButton extends StatelessWidget {
  const AppRetryButton({
    super.key,
    required this.onRetry,
    this.label = 'Retry',
  });

  final VoidCallback onRetry;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppButton.secondary(
        label: label,
        icon: Icons.refresh_rounded,
        onPressed: onRetry,
        isFullWidth: false,
      ),
    );
  }
}