import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Semantic status values used across roles.
/// Keep these values stable — they map 1:1 with backend statuses later.
enum AppStatus {
  draft,
  published,
  archived,
  active,
  inactive,
  suspended,
  pending,
  submitted,
  graded,
  resubmissionRequired,
}

/// Colored status chip that maps AppStatus to a consistent visual.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.status,
    this.label,
    this.dense = false,
  });

  final AppStatus status;
  final String? label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, text) = _resolve();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
        vertical: dense ? 2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label ?? text,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontSize: dense ? 10 : 11,
        ),
      ),
    );
  }

  (Color, Color, String) _resolve() {
    switch (status) {
      case AppStatus.draft:
        return (
        AppColors.statusDraftBg,
        AppColors.statusDraftFg,
        'DRAFT',
        );
      case AppStatus.published:
        return (
        AppColors.statusPublishedBg,
        AppColors.statusPublishedFg,
        'PUBLISHED',
        );
      case AppStatus.archived:
        return (
        AppColors.statusArchivedBg,
        AppColors.statusArchivedFg,
        'ARCHIVED',
        );
      case AppStatus.active:
        return (
        AppColors.statusActiveBg,
        AppColors.statusActiveFg,
        'ACTIVE',
        );
      case AppStatus.inactive:
        return (
        AppColors.statusInactiveBg,
        AppColors.statusInactiveFg,
        'INACTIVE',
        );
      case AppStatus.suspended:
        return (
        AppColors.statusSuspendedBg,
        AppColors.statusSuspendedFg,
        'SUSPENDED',
        );
      case AppStatus.pending:
        return (
        AppColors.statusPendingBg,
        AppColors.statusPendingFg,
        'PENDING',
        );
      case AppStatus.submitted:
        return (
        AppColors.statusSubmittedBg,
        AppColors.statusSubmittedFg,
        'SUBMITTED',
        );
      case AppStatus.graded:
        return (
        AppColors.statusGradedBg,
        AppColors.statusGradedFg,
        'GRADED',
        );
      case AppStatus.resubmissionRequired:
        return (
        AppColors.statusResubmissionBg,
        AppColors.statusResubmissionFg,
        'RESUBMISSION',
        );
    }
  }
}