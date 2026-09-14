import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../widgets/instructor_course_card.dart';

class InstructorCoursesPage extends StatefulWidget {
  const InstructorCoursesPage({super.key});

  @override
  State<InstructorCoursesPage> createState() =>
      _InstructorCoursesPageState();
}

class _InstructorCoursesPageState extends State<InstructorCoursesPage> {
  static const _instructorId = 'user_instructor_001';
  int _tab = 0; // 0=All, 1=Draft, 2=Published, 3=Archived

  List<MockCourse> get _myCourses =>
      MockCourses.byInstructor(_instructorId);

  List<MockCourse> get _filtered {
    final all = _myCourses;
    switch (_tab) {
      case 0:
        return all;
      case 1:
        return all.where((c) => c.status == CourseStatus.draft).toList();
      case 2:
        return all
            .where((c) => c.status == CourseStatus.published)
            .toList();
      case 3:
        return all
            .where((c) => c.status == CourseStatus.archived)
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Courses'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Course',
            onPressed: () => Navigator.of(context)
                .pushNamed(AppRoutes.instructorCreateCourse),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              scrollDirection: Axis.horizontal,
              children: [
                _chip('All', 0),
                const SizedBox(width: AppSpacing.xs),
                _chip('Draft', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Published', 2),
                const SizedBox(width: AppSpacing.xs),
                _chip('Archived', 3),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: list.isEmpty
            ? AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: _emptyTitle,
          message: _emptyMessage,
          actionLabel: 'Create Course',
          onAction: () => Navigator.of(context)
              .pushNamed(AppRoutes.instructorCreateCourse),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final c = list[i];
            return InstructorCourseCard(
              course: c,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorCourseDetails,
                arguments: c.id,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorCreateCourse),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Course'),
      ),
    );
  }

  String get _emptyTitle {
    switch (_tab) {
      case 1:
        return 'No draft courses';
      case 2:
        return 'No published courses';
      case 3:
        return 'No archived courses';
      default:
        return 'No courses yet';
    }
  }

  String get _emptyMessage {
    switch (_tab) {
      case 1:
        return 'Drafts you create will appear here.';
      case 2:
        return 'Publish a course to make it visible to students.';
      case 3:
        return 'Archived courses will appear here.';
      default:
        return 'Start by creating your first course.';
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
}