import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../student/data/models/submission.dart';
import '../../providers/instructor_assignment_provider.dart';

class InstructorSubmissionDetailsPage extends StatefulWidget {
  const InstructorSubmissionDetailsPage({
    super.key,
    required this.submissionId,
  });

  final String submissionId;

  @override
  State<InstructorSubmissionDetailsPage> createState() =>
      _InstructorSubmissionDetailsPageState();
}

class _InstructorSubmissionDetailsPageState
    extends State<InstructorSubmissionDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InstructorAssignmentProvider>()
          .loadSubmission(widget.submissionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorAssignmentProvider>();
    final state = p.submissionDetailState(widget.submissionId);
    final s = p.submission(widget.submissionId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Submission')),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading && s == null
            ? const AppLoading(message: 'Loading submission…')
            : state == LoadState.error && s == null
            ? AppErrorState(
          title: 'Could not load submission',
          message: 'Please try again.',
          onRetry: () => p.loadSubmission(
            widget.submissionId,
            force: true,
          ),
        )
            : s == null
            ? const Center(
            child: Text('Submission not found'))
            : _body(s),
      ),
      bottomNavigationBar: s == null
          ? null
          : (s.status != SubmissionStatus.graded
          ? _cta(context, s)
          : null),
    );
  }

  Widget _body(Submission s) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _header(s),
        const SizedBox(height: AppSpacing.lg),
        if (s.textContent != null) ...[
          Text('Text submission',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xs),
          _card(child: Text(s.textContent!,
              style: AppTextStyles.bodySmall)),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (s.fileName != null) ...[
          Text('Attached file', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xs),
          _card(
            child: Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(s.fileName!,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (s.status == SubmissionStatus.graded) ...[
          Text('Grade', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xs),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Score',
                        style: AppTextStyles.labelMedium),
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
        ],
      ],
    );
  }

  Widget _header(Submission s) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(
            name: s.studentName ?? s.studentId,
            size: 48,
            borderWidth: 2,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.studentName ?? s.studentId,
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(s.assignmentTitle,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          _statusChip(s.status),
        ],
      ),
    );
  }

  Widget _statusChip(SubmissionStatus status) {
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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _cta(BuildContext context, Submission s) {
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
            arguments: {
              'submissionId': s.id,
            },
          ),
        ),
      ),
    );
  }
}