import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../mock_data/mock_categories.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../widgets/course_card.dart';

class StudentCoursesPage extends StatefulWidget {
  const StudentCoursesPage({super.key});

  @override
  State<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends State<StudentCoursesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _categoryId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockCourse> get _filtered {
    final base = MockCourses.published;
    return base.where((c) {
      final matchesCategory =
          _categoryId == null || c.categoryId == _categoryId;
      final matchesQuery = _query.isEmpty ||
          c.title.toLowerCase().contains(_query.toLowerCase()) ||
          c.instructorName.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = MockCategories.active;
    final courses = _filtered;

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
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.xs),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _categoryChip(
                      label: 'All',
                      selected: _categoryId == null,
                      onTap: () => setState(() => _categoryId = null),
                    );
                  }
                  final cat = categories[i - 1];
                  return _categoryChip(
                    label: cat.name,
                    selected: _categoryId == cat.id,
                    onTap: () =>
                        setState(() => _categoryId = cat.id),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: courses.isEmpty
                  ? const AppEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No courses found',
                message:
                'Try a different search or category filter.',
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                itemCount: courses.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final c = courses[i];
                  return CourseCard(
                    course: c,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.studentCourseDetails,
                      arguments: c.id,
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

  Widget _categoryChip({
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