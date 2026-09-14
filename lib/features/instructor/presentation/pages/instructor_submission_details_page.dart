import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_submission.dart';

class InstructorSubmissionDetailsPage extends StatelessWidget {
  const InstructorSubmissionDetailsPage({
    super.key,
    required this.submissionId,
  });

  final String submissionId;

  @override
  Widget build(BuildContext context) {
    final s = _find();
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Submission not found')),
      );
    }

    final canGrade = s.status != SubmissionStatus.graded;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Submission')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _studentCard(s),
            const SizedBox(height: AppSpacing.lg),

            _sectionTitle('Assignment'),
            const SizedBox(height: AppSpacing.xs),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.assignmentTitle,
                      style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted ${Formatters.relative(s.submittedAt)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (s.textContent != null) ...[
              _sectionTitle('Text submission'),
              const SizedBox(height: AppSpacing.xs),
              _card(
                child: Text(s.textContent!,
                    style: AppTextStyles.bodySmall),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            if (s.fileName != null) ...[
              _sectionTitle('Attached file'),
              const SizedBox(height: AppSpacing.xs),
              _card(
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        s.fileName!,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            if (s.status == SubmissionStatus.graded) ...[
              _sectionTitle('Grade'),
              const SizedBox(height: AppSpacing.xs),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Score', style: AppTextStyles.labelMedium),
                        const Spacer(),
                        Text(
                          '${s.score}/${s.maxPoints ?? 0}',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                    if (s.feedback != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text('Feedback',
                          style: AppTextStyles.labelMedium),
                      const SizedBox(height: 4),
                      Text(s.feedback!,
                          style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            if (s.status == SubmissionStatus.resubmissionRequired) ...[
              _sectionTitle('Resubmission requested'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Resubmission required',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.danger),
                        ),
                      ],
                    ),
                    if (s.feedback != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(s.feedback!,
                          style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
      bottomNavigationBar: canGrade
          ? _cta(context, s)
          : null,
    );
  }

  MockSubmission? _find() {
    for (final s in MockSubmissions.all) {
      if (s.id == submissionId) return s;
    }
    return null;
  }

  Widget _studentCard(MockSubmission s) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: s.studentName, size: 48, borderWidth: 2),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.studentName,
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(s.studentId, style: AppTextStyles.caption),
              ],
            ),
          ),
          _statusChip(s),
        ],
      ),
    );
  }

  Widget _statusChip(MockSubmission s) {
    switch (s.status) {
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

  Widget _sectionTitle(String title) =>
      Text(title, style: AppTextStyles.headingSmall);

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );

  Widget _cta(BuildContext context, MockSubmission s) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: AppButton.primary(
          label: s.status == SubmissionStatus.resubmissionRequired
              ? 'Re-grade Submission'
              : 'Grade Submission',
          icon: Icons.grading_rounded,
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorGradeSubmission,
            arguments: s.id,
          ),
        ),
      ),
    );
  }
}