import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_assignment.dart';
import '../../../../mock_data/models/mock_submission.dart';

class InstructorAssignmentsPage extends StatefulWidget {
  const InstructorAssignmentsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorAssignmentsPage> createState() =>
      _InstructorAssignmentsPageState();
}

class _InstructorAssignmentsPageState
    extends State<InstructorAssignmentsPage> {
  int _tab = 0; // 0=All, 1=Draft, 2=Published
  late List<MockAssignment> _assignments;

  @override
  void initState() {
    super.initState();
    _assignments = List.of(MockAssignments.byCourse(widget.courseId));
  }

  List<MockAssignment> get _filtered {
    switch (_tab) {
      case 1:
        return _assignments
            .where((a) => a.status == AssignmentStatus.draft)
            .toList();
      case 2:
        return _assignments
            .where((a) => a.status == AssignmentStatus.published)
            .toList();
      default:
        return _assignments;
    }
  }

  int _submissionCount(String assignmentId) =>
      MockSubmissions.byAssignment(assignmentId).length;

  int _pendingCount(String assignmentId) => MockSubmissions.byAssignment(
    assignmentId,
  ).where((s) => s.status == SubmissionStatus.submitted).length;

  Future<void> _delete(MockAssignment a) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete assignment?',
      message:
      '"${a.title}" and all its submissions will be removed. This '
          'cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _assignments.removeWhere((x) => x.id == a.id));
    AppSnackbar.showSuccess(context, 'Assignment deleted (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

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
        child: list.isEmpty
            ? AppEmptyState(
          icon: Icons.assignment_outlined,
          title: _emptyTitle,
          message:
          'Create an assignment to evaluate student work.',
          actionLabel: 'Create Assignment',
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorCreateAssignment,
            arguments: widget.courseId,
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _assignmentCard(list[i]),
        ),
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

  String get _emptyTitle {
    switch (_tab) {
      case 1:
        return 'No draft assignments';
      case 2:
        return 'No published assignments';
      default:
        return 'No assignments yet';
    }
  }

  Widget _assignmentCard(MockAssignment a) {
    final submissions = _submissionCount(a.id);
    final pending = _pendingCount(a.id);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorSubmissions,
          arguments: a.id,
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
                    child: Text(
                      a.title,
                      style: AppTextStyles.headingSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                  _meta(Icons.assignment_turned_in_outlined,
                      '$submissions submissions'),
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
                      arguments: a.id,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.instructorSubmissions,
                      arguments: a.id,
                    ),
                    icon: const Icon(Icons.people_alt_outlined, size: 18),
                    label: const Text('Submissions'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _delete(a),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
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

  Widget _meta(IconData icon, String label, {bool highlight = false}) {
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
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: highlight ? color : null,
              fontWeight:
              highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
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