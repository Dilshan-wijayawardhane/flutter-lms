import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/data/models/assignment.dart';
import '../../../student/data/models/submission.dart';
import '../../providers/instructor_assignment_provider.dart';

class InstructorAssignmentsPage extends StatefulWidget {
  const InstructorAssignmentsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorAssignmentsPage> createState() =>
      _InstructorAssignmentsPageState();
}

class _InstructorAssignmentsPageState
    extends State<InstructorAssignmentsPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InstructorAssignmentProvider>()
          .loadAssignments(widget.courseId);
    });
  }

  List<Assignment> _filtered(InstructorAssignmentProvider p) {
    final list = p.assignmentsFor(widget.courseId);
    switch (_tab) {
      case 1:
        return list
            .where((a) => a.status == AssignmentStatus.draft)
            .toList();
      case 2:
        return list
            .where((a) => a.status == AssignmentStatus.published)
            .toList();
      default:
        return list;
    }
  }

  Future<void> _delete(Assignment a) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete assignment?',
      message:
      '"${a.title}" and all submissions will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final ok = await context
        .read<InstructorAssignmentProvider>()
        .deleteAssignment(
      courseId: widget.courseId,
      assignmentId: a.id,
    );
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Assignment deleted.' : 'Could not delete.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorAssignmentProvider>();
    final state = p.listStateFor(widget.courseId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assignments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                _chip('All', 0),
                const SizedBox(width: AppSpacing.xs),
                _chip('Draft', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Published', 2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading &&
            p.assignmentsFor(widget.courseId).isEmpty
            ? const AppLoading(message: 'Loading assignments…')
            : state == LoadState.error
            ? AppErrorState(
          title: 'Could not load assignments',
          message: p.listErrorFor(widget.courseId) ??
              'Please try again.',
          onRetry: () => p.loadAssignments(
            widget.courseId,
            force: true,
          ),
        )
            : _body(p),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateAssignment,
          arguments: widget.courseId,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Assignment'),
      ),
    );
  }

  Widget _body(InstructorAssignmentProvider p) {
    final list = _filtered(p);
    if (list.isEmpty) {
      return AppEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No assignments yet',
        message: 'Create an assignment to evaluate student work.',
        actionLabel: 'Create Assignment',
        onAction: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateAssignment,
          arguments: widget.courseId,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          p.loadAssignments(widget.courseId, force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _card(p, list[i]),
      ),
    );
  }

  Widget _card(InstructorAssignmentProvider p, Assignment a) {
    final submissions = p.submissionsFor(a.id);
    final pending = submissions
        .where((s) => s.status == SubmissionStatus.submitted)
        .length;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorSubmissions,
          arguments: {
            'courseId': widget.courseId,
            'assignmentId': a.id,
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
                  Expanded(
                    child: Text(a.title,
                        style: AppTextStyles.headingSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (a.status == AssignmentStatus.published)
                    const AppStatusChip(status: AppStatus.published)
                  else
                    const AppStatusChip(status: AppStatus.draft),
                ],
              ),
              const SizedBox(height: 4),
              Text(a.courseName, style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _meta(
                    Icons.event_outlined,
                    a.dueDate == null
                        ? 'No due date'
                        : 'Due ${Formatters.date(a.dueDate)}',
                  ),
                  _meta(Icons.emoji_events_outlined,
                      '${a.maxPoints} pts'),
                  if (pending > 0)
                    _meta(Icons.pending_actions_outlined,
                        '$pending to grade',
                        highlight: true),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.instructorEditAssignment,
                      arguments: {
                        'courseId': widget.courseId,
                        'assignmentId': a.id,
                      },
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.instructorSubmissions,
                      arguments: {
                        'courseId': widget.courseId,
                        'assignmentId': a.id,
                      },
                    ),
                    icon: const Icon(Icons.people_alt_outlined, size: 18),
                    label: const Text('Submissions'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _delete(a),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String label,
      {bool highlight = false}) {
    final color =
    highlight ? AppColors.warning : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.warning.withValues(alpha: 0.12)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
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