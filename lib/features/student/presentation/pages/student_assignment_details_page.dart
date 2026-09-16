import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/submission.dart';
import '../../providers/assignment_provider.dart';

class StudentAssignmentDetailsPage extends StatefulWidget {
  const StudentAssignmentDetailsPage({
    super.key,
    required this.assignmentId,
  });

  final String assignmentId;

  @override
  State<StudentAssignmentDetailsPage> createState() =>
      _StudentAssignmentDetailsPageState();
}

class _StudentAssignmentDetailsPageState
    extends State<StudentAssignmentDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().loadDetails(widget.assignmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    final state = provider.detailStateFor(widget.assignmentId);
    final assignment = provider.assignmentById(widget.assignmentId);
    final submission = provider.submissionFor(widget.assignmentId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Assignment')),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading && assignment == null
            ? const AppLoading(message: 'Loading assignment…')
            : state == LoadState.error && assignment == null
            ? AppErrorState(
          title: 'Could not load assignment',
          message: provider.detailErrorFor(widget.assignmentId) ??
              'Please try again.',
          onRetry: () => provider
              .loadDetails(widget.assignmentId, force: true),
        )
            : assignment == null
            ? const Center(
            child: Text('Assignment not found'))
            : _body(provider, assignment, submission),
      ),
      bottomNavigationBar: assignment == null
          ? null
          : _cta(context, provider, assignment, submission),
    );
  }

  Widget _body(
      AssignmentProvider provider,
      dynamic assignment,
      Submission? submission,
      ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _header(assignment, submission),
        const SizedBox(height: AppSpacing.lg),
        Text('Description', style: AppTextStyles.headingSmall),
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
        if (submission != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Your Submission', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xs),
          _submissionCard(submission),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _header(dynamic assignment, Submission? submission) {
    final status = submission?.status;
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
                child: Text(assignment.title,
                    style: AppTextStyles.headingSmall),
              ),
              const SizedBox(width: AppSpacing.xs),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(assignment.courseName, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                assignment.dueDate == null
                    ? 'No due date'
                    : 'Due ${Formatters.date(assignment.dueDate)}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.emoji_events_outlined,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${assignment.maxPoints} pts',
                  style: AppTextStyles.caption),
            ],
          ),
        ],
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
            status: AppStatus.resubmissionRequired);
      case SubmissionStatus.graded:
        return const AppStatusChip(status: AppStatus.graded);
    }
  }

  Widget _submissionCard(Submission s) {
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
                  child: Text(s.fileName!,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (s.submittedAt != null)
            Text('Submitted ${Formatters.relative(s.submittedAt)}',
                style: AppTextStyles.caption),
          if (s.status == SubmissionStatus.graded &&
              s.score != null) ...[
            const Divider(height: AppSpacing.lg),
            Row(
              children: [
                Text('Score', style: AppTextStyles.labelMedium),
                const Spacer(),
                Text('${s.score}/${s.maxPoints ?? 0}',
                    style: AppTextStyles.headingSmall
                        .copyWith(color: AppColors.success)),
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
                Text('Resubmission Required',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.danger)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(s.feedback!, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget? _cta(
      BuildContext context,
      AssignmentProvider provider,
      dynamic assignment,
      Submission? submission,
      ) {
    final status = submission?.status;
    final canEdit = status == null ||
        status == SubmissionStatus.pending ||
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
              : (submission == null
              ? 'Submit Assignment'
              : 'Update Submission'),
          icon: Icons.upload_file_rounded,
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.studentAssignmentSubmission,
            arguments: assignment.id,
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