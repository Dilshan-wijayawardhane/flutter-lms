import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../student/data/models/course.dart';
import '../../../student/providers/instructor_course_provider.dart';
import '../widgets/instructor_course_card.dart';

class InstructorCoursesPage extends StatefulWidget {
  const InstructorCoursesPage({super.key});

  @override
  State<InstructorCoursesPage> createState() =>
      _InstructorCoursesPageState();
}

class _InstructorCoursesPageState extends State<InstructorCoursesPage> {
  int _tab = 0; // 0=All, 1=Draft, 2=Published, 3=Archived

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<InstructorCourseProvider>();
      if (p.listState != LoadState.success) p.loadMyCourses();
    });
  }

  List<Course> _filtered(InstructorCourseProvider p) {
    switch (_tab) {
      case 1:
        return p.courses
            .where((c) => c.status == CourseStatus.draft)
            .toList();
      case 2:
        return p.courses
            .where((c) => c.status == CourseStatus.published)
            .toList();
      case 3:
        return p.courses
            .where((c) => c.status == CourseStatus.archived)
            .toList();
      default:
        return p.courses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstructorCourseProvider>();

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
      body: SafeArea(top: false, child: _buildBody(provider)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorCreateCourse),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Course'),
      ),
    );
  }

  Widget _buildBody(InstructorCourseProvider provider) {
    if (provider.listState == LoadState.loading &&
        provider.courses.isEmpty) {
      return const AppLoading(message: 'Loading your courses…');
    }
    if (provider.listState == LoadState.error &&
        provider.courses.isEmpty) {
      return AppErrorState(
        title: 'Could not load your courses',
        message: provider.errorMessage ?? 'Please try again.',
        onRetry: () => provider.loadMyCourses(force: true),
      );
    }

    final list = _filtered(provider);
    if (list.isEmpty) {
      return AppEmptyState(
        icon: Icons.menu_book_outlined,
        title: _emptyTitle,
        message: 'Create your first course to get started.',
        actionLabel: 'Create Course',
        onAction: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorCreateCourse),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMyCourses(force: true),
      child: ListView.separated(
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