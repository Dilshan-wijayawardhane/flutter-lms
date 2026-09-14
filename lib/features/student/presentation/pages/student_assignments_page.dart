import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_assignment.dart';
import '../../../../mock_data/models/mock_submission.dart';
import '../widgets/assignment_card.dart';

class StudentAssignmentsPage extends StatefulWidget {
  const StudentAssignmentsPage({super.key});

  @override
  State<StudentAssignmentsPage> createState() =>
      _StudentAssignmentsPageState();
}

class _StudentAssignmentsPageState extends State<StudentAssignmentsPage> {
  int _filter = 0; // 0=All, 1=Pending, 2=Submitted, 3=Graded

  @override
  Widget build(BuildContext context) {
    final assignments = MockAssignments.published;
    final filtered = assignments.where((a) {
      final sub = MockSubmissions.byStudentAndAssignment(
        'user_student_001',
        a.id,
      );
      switch (_filter) {
        case 0:
          return true;
        case 1:
          return sub == null || sub.status == SubmissionStatus.pending;
        case 2:
          return sub?.status == SubmissionStatus.submitted ||
              sub?.status == SubmissionStatus.resubmissionRequired;
        case 3:
          return sub?.status == SubmissionStatus.graded;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Assignments')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
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
                  _chip('Pending', 1),
                  const SizedBox(width: AppSpacing.xs),
                  _chip('Submitted', 2),
                  const SizedBox(width: AppSpacing.xs),
                  _chip('Graded', 3),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AppEmptyState(
                icon: Icons.assignment_outlined,
                title: 'No assignments',
                message:
                'Assignments for this filter will appear here.',
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final a = filtered[i];
                  final sub = MockSubmissions.byStudentAndAssignment(
                    'user_student_001',
                    a.id,
                  );
                  return AssignmentCard(
                    assignment: a,
                    submission: sub,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.studentAssignmentDetails,
                      arguments: a.id,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int index) {
    final active = _filter == index;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        alignment: Alignment.center,
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

  TextStyle _appTextStyleActive(bool active) => TextStyle();

  TextStyle AppTextStyles_label(bool active) => TextStyle();
}