import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_assignment.dart';
import '../../../../mock_data/models/mock_submission.dart';

class StudentAssignmentDetailsPage extends StatelessWidget {
  const StudentAssignmentDetailsPage({
    super.key,
    required this.assignmentId,
  });

  final String assignmentId;

  @override
  Widget build(BuildContext context) {
    final assignment = _find(assignmentId);
    if (assignment == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Assignment not found')),
      );
    }

    final submission = MockSubmissions.byStudentAndAssignment(
      'user_student_001',
      assignment.id,
    );
    final status = submission?.status ?? SubmissionStatus.pending;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Assignment')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _header(assignment, status),
            const SizedBox(height: AppSpacing.lg),
            _section('Description'),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                assignment.description,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            if (assignment.attachmentName != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _section('Attachment'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        assignment.attachmentName!,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (submission != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _section('Your Submission'),
              const SizedBox(height: AppSpacing.xs),
              _submissionCard(submission),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: _cta(context, assignment, submission, status),
    );
  }

  MockAssignment? _find(String id) {
    for (final a in MockAssignments.all) {
      if (a.id == id) return a;
    }
    return null;
  }

  Widget _header(MockAssignment a, SubmissionStatus status) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(a.title, style: AppTextStyles.headingSmall),
              ),
              const SizedBox(width: AppSpacing.xs),
              _status(status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(a.courseName, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                a.dueDate == null
                    ? 'No due date'
                    : 'Due ${Formatters.date(a.dueDate)}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.emoji_events_outlined,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${a.maxPoints} pts',
                  style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _status(SubmissionStatus status) {
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

  Widget _submissionCard(MockSubmission s) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s.textContent != null) ...[
            Text('Text', style: AppTextStyles.labelMedium),
            const SizedBox(height: 4),
            Text(s.textContent!, style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (s.fileName != null) ...[
            Text('File', style: AppTextStyles.labelMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    s.fileName!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (s.submittedAt != null)
            Text(
              'Submitted ${Formatters.relative(s.submittedAt)}',
              style: AppTextStyles.caption,
            ),
          if (s.status == SubmissionStatus.graded &&
              s.score != null) ...[
            const Divider(height: AppSpacing.lg),
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
              Text('Feedback', style: AppTextStyles.labelMedium),
              const SizedBox(height: 4),
              Text(s.feedback!, style: AppTextStyles.bodySmall),
            ],
          ],
          if (s.status == SubmissionStatus.resubmissionRequired &&
              s.feedback != null) ...[
            const Divider(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.danger, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Resubmission Required',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.danger),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(s.feedback!, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _section(String title) => Text(title,
      style: AppTextStyles.headingSmall);

  Widget? _cta(
      BuildContext context,
      MockAssignment a,
      MockSubmission? s,
      SubmissionStatus status,
      ) {
    final canEdit = status == SubmissionStatus.pending ||
        status == SubmissionStatus.resubmissionRequired;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: canEdit
            ? AppButton.primary(
          label: status == SubmissionStatus.resubmissionRequired
              ? 'Resubmit Assignment'
              : s == null
              ? 'Submit Assignment'
              : 'Update Submission',
          icon: Icons.upload_file_rounded,
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.studentAssignmentSubmission,
            arguments: a.id,
          ),
        )
            : AppButton.secondary(
          label: status == SubmissionStatus.graded
              ? 'Graded — Editing Disabled'
              : 'Submitted',
          icon: status == SubmissionStatus.graded
              ? Icons.lock_outline_rounded
              : Icons.check_circle_outline_rounded,
          onPressed: null,
        ),
      ),
    );
  }
}