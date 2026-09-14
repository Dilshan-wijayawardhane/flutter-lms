import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_assignment.dart';
import '../../../../mock_data/models/mock_submission.dart';
import '../widgets/submission_card.dart';

class InstructorSubmissionsPage extends StatefulWidget {
  const InstructorSubmissionsPage({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  State<InstructorSubmissionsPage> createState() =>
      _InstructorSubmissionsPageState();
}

class _InstructorSubmissionsPageState
    extends State<InstructorSubmissionsPage> {
  MockAssignment? _assignment;
  int _tab = 0; // 0=All, 1=Submitted, 2=Resubmission, 3=Graded
  late List<MockSubmission> _submissions;

  @override
  void initState() {
    super.initState();
    _assignment = _findAssignment();
    _submissions = List.of(
      MockSubmissions.byAssignment(widget.assignmentId),
    );
  }

  MockAssignment? _findAssignment() {
    for (final a in MockAssignments.all) {
      if (a.id == widget.assignmentId) return a;
    }
    return null;
  }

  List<MockSubmission> get _filtered {
    switch (_tab) {
      case 1:
        return _submissions
            .where((s) => s.status == SubmissionStatus.submitted)
            .toList();
      case 2:
        return _submissions
            .where((s) =>
        s.status == SubmissionStatus.resubmissionRequired)
            .toList();
      case 3:
        return _submissions
            .where((s) => s.status == SubmissionStatus.graded)
            .toList();
      default:
        return _submissions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = _assignment;
    if (assignment == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Assignment not found')),
      );
    }
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          assignment.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
        child: list.isEmpty
            ? const AppEmptyState(
          icon: Icons.assignment_turned_in_outlined,
          title: 'No submissions',
          message:
          'Submissions for this filter will appear here once '
              'students submit their work.',
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final s = list[i];
            return SubmissionCard(
              submission: s,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorSubmissionDetails,
                arguments: s.id,
              ),
            );
          },
        ),
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