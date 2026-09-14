import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_courses.dart';
import '../widgets/course_card.dart';

class StudentMyCoursesPage extends StatefulWidget {
  const StudentMyCoursesPage({super.key});

  @override
  State<StudentMyCoursesPage> createState() => _StudentMyCoursesPageState();
}

class _StudentMyCoursesPageState extends State<StudentMyCoursesPage> {
  int _tab = 0; // 0 = In Progress, 1 = Completed

  @override
  Widget build(BuildContext context) {
    final enrolled = MockCourses.studentEnrolled;
    final inProgress = enrolled
        .where((c) => c.progressPercent < 100)
        .toList();
    final completed =
    enrolled.where((c) => c.progressPercent >= 100).toList();

    final list = _tab == 0 ? inProgress : completed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Learning'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                _tabButton('In Progress', 0),
                const SizedBox(width: AppSpacing.xs),
                _tabButton('Completed', 1),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: list.isEmpty
            ? AppEmptyState(
          icon: _tab == 0
              ? Icons.play_lesson_outlined
              : Icons.verified_outlined,
          title: _tab == 0
              ? 'No courses in progress'
              : 'No completed courses yet',
          message: _tab == 0
              ? 'Enroll in a course to get started.'
              : 'Finish a course to see it here.',
          actionLabel: 'Browse Courses',
          onAction: () => Navigator.of(context)
              .pushNamed(AppRoutes.studentCourses),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final c = list[i];
            return CourseCard(
              course: c,
              showProgress: true,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.studentLearning,
                arguments: c.id,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primarySurface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: active ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: active
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}