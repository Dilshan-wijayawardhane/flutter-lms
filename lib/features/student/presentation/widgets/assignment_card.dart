import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../mock_data/models/mock_assignment.dart';
import '../../../../mock_data/models/mock_submission.dart';

/// Assignment row used on the student assignments list.
/// Displays assignment title, course, due date, and submission status.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    this.submission,
    this.onTap,
  });

  final MockAssignment assignment;
  final MockSubmission? submission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = submission?.status;
    final dueDate = assignment.dueDate;
    final isOverdue = dueDate != null &&
        dueDate.isBefore(DateTime.now()) &&
        (status == null || status == SubmissionStatus.pending);

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
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _statusChip(status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                assignment.courseName,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: isOverdue
                        ? AppColors.danger
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dueDate == null
                        ? 'No due date'
                        : 'Due ${Formatters.date(dueDate)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isOverdue
                          ? AppColors.danger
                          : AppColors.textTertiary,
                      fontWeight:
                      isOverdue ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${assignment.maxPoints} pts',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              if (submission?.score != null &&
                  submission!.status == SubmissionStatus.graded) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    'Score: ${submission!.score}/${submission!.maxPoints}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(SubmissionStatus? status) {
    if (status == null) {
      return const AppStatusChip(status: AppStatus.pending);
    }
    switch (status) {
      case SubmissionStatus.pending:
        return const AppStatusChip(status: AppStatus.pending);
      case SubmissionStatus.submitted:
        return const AppStatusChip(status: AppStatus.submitted);
      case SubmissionStatus.resubmissionRequired:
        return const AppStatusChip(
          status: AppStatus.resubmissionRequired,
        );
      case SubmissionStatus.graded:
        return const AppStatusChip(status: AppStatus.graded);
    }
  }
}