import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../student/data/models/submission.dart';
import '../../providers/instructor_assignment_provider.dart';

class InstructorSubmissionsPage extends StatefulWidget {
  const InstructorSubmissionsPage({
    super.key,
    required this.courseId,
    required this.assignmentId,
  });

  final String courseId;
  final String assignmentId;

  @override
  State<InstructorSubmissionsPage> createState() =>
      _InstructorSubmissionsPageState();
}

class _InstructorSubmissionsPageState
    extends State<InstructorSubmissionsPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InstructorAssignmentProvider>()
          .loadSubmissions(widget.assignmentId);
    });
  }

  List<Submission> _filtered(
      InstructorAssignmentProvider p,
      List<Submission> list,
      ) {
    switch (_tab) {
      case 1:
        return list
            .where((s) => s.status == SubmissionStatus.submitted)
            .toList();
      case 2:
        return list
            .where((s) =>
        s.status == SubmissionStatus.resubmissionRequired)
            .toList();
      case 3:
        return list
            .where((s) => s.status == SubmissionStatus.graded)
            .toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorAssignmentProvider>();
    final state = p.submissionsStateFor(widget.assignmentId);
    final all = p.submissionsFor(widget.assignmentId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submissions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              scrollDirection: Axis.horizontal,
              children: [
                _chip('All', 0),
                const SizedBox(width: AppSpacing.xs),
                _chip('Submitted', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Resubmission', 2),
                const SizedBox(width: AppSpacing.xs),
                _chip('Graded', 3),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading && all.isEmpty
            ? const AppLoading(message: 'Loading submissions…')
            : state == LoadState.error && all.isEmpty
            ? AppErrorState(
          title: 'Could not load submissions',
          message: 'Please try again.',
          onRetry: () => p.loadSubmissions(
            widget.assignmentId,
            force: true,
          ),
        )
            : _body(p, _filtered(p, all)),
      ),
    );
  }

  Widget _body(
      InstructorAssignmentProvider p,
      List<Submission> list,
      ) {
    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.assignment_turned_in_outlined,
        title: 'No submissions',
        message: 'Student submissions will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          p.loadSubmissions(widget.assignmentId, force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _card(list[i]),
      ),
    );
  }

  Widget _card(Submission s) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorSubmissionDetails,
          arguments: {
            'courseId': widget.courseId,
            'assignmentId': widget.assignmentId,
            'submissionId': s.id,
          },
        ),
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
                  AppAvatar(name: s.studentName ?? s.studentId, size: 36),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.studentName ?? s.studentId,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.submittedAt == null
                              ? 'Not submitted'
                              : Formatters.relative(s.submittedAt),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _statusChip(s.status),
                ],
              ),
              if (s.status == SubmissionStatus.graded &&
                  s.score != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                    AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusPill,
                    ),
                  ),
                  child: Text(
                    '${s.score}/${s.maxPoints ?? 0}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ],
          ),
        ),
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

  Widget _chip(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color:
          active ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}