import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../mock_data/models/mock_enrollment.dart';

/// Enrollment row used on the admin enrollments list.
class EnrollmentCard extends StatelessWidget {
  const EnrollmentCard({
    super.key,
    required this.enrollment,
    this.onTap,
  });

  final MockEnrollment enrollment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = (enrollment.progressPercent / 100).clamp(0.0, 1.0);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(name: enrollment.studentName, size: 36),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enrollment.studentName,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          enrollment.courseName,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _statusChip(),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor:
                  const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    '${enrollment.progressPercent}% complete',
                    style: AppTextStyles.caption,
                  ),
                  const Spacer(),
                  Text(
                    'Enrolled ${Formatters.relative(enrollment.enrolledAt)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip() {
    switch (enrollment.status) {
      case EnrollmentStatus.active:
        return const AppStatusChip(status: AppStatus.active, dense: true);
      case EnrollmentStatus.completed:
        return const AppStatusChip(
          status: AppStatus.published,
          dense: true,
          label: 'COMPLETED',
        );
      case EnrollmentStatus.cancelled:
        return const AppStatusChip(
          status: AppStatus.inactive,
          dense: true,
          label: 'CANCELLED',
        );
    }
  }
}