import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../providers/category_provider.dart';
import '../../providers/course_provider.dart' hide LoadState;
import '../widgets/course_card.dart';

class StudentCoursesPage extends StatefulWidget {
  const StudentCoursesPage({super.key});

  @override
  State<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends State<StudentCoursesPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = context.read<CategoryProvider>();
      if (categories.state != LoadState.success) categories.load();
      final courses = context.read<CourseProvider>();
      if (courses.browseState != LoadState.success) courses.browse();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>();
    final courses = context.watch<CourseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Courses'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Search courses or instructors',
                onChanged: (v) {
                  // Debounce-lite: fire on each pause; backend is fast.
                  courses.setSearch(v);
                },
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: categories.categories.length + 1,
                separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.xs),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _chip(
                      label: 'All',
                      selected: courses.categoryId == null,
                      onTap: () => courses.setCategory(null),
                    );
                  }
                  final cat = categories.categories[i - 1];
                  return _chip(
                    label: cat.name,
                    selected: courses.categoryId == cat.id,
                    onTap: () => courses.setCategory(cat.id),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildBody(courses)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CourseProvider courses) {
    if (courses.browseState == LoadState.loading &&
        courses.courses.isEmpty) {
      return const AppLoading(message: 'Loading courses…');
    }

    if (courses.browseState == LoadState.error &&
        courses.courses.isEmpty) {
      return AppErrorState(
        title: 'Could not load courses',
        message: courses.browseError ?? 'Please try again.',
        onRetry: () => courses.browse(force: true),
      );
    }

    if (courses.courses.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No courses found',
        message: 'Try a different search or category filter.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => courses.browse(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        itemCount: courses.courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final c = courses.courses[i];
          return CourseCard(
            course: c,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.studentCourseDetails,
              arguments: c.id,
            ),
          );
        },
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color:
          selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}