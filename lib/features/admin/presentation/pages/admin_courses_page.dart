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
import '../widgets/admin_course_card.dart';

/// Filter arguments returned from [AdminCourseFilterPage].
class AdminCourseFilterArgs {
  const AdminCourseFilterArgs({this.status, this.categoryId});

  final CourseStatus? status;
  final String? categoryId;
}

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({super.key});

  @override
  State<AdminCoursesPage> createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  CourseStatus? _statusFilter;
  String? _categoryIdFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockCourse> get _filtered {
    return MockCourses.all.where((c) {
      final matchesQuery = _query.isEmpty ||
          c.title.toLowerCase().contains(_query.toLowerCase()) ||
          c.instructorName.toLowerCase().contains(_query.toLowerCase());
      final matchesStatus =
          _statusFilter == null || c.status == _statusFilter;
      final matchesCategory =
          _categoryIdFilter == null || c.categoryId == _categoryIdFilter;
      return matchesQuery && matchesStatus && matchesCategory;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _statusFilter != null || _categoryIdFilter != null;

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _categoryIdFilter = null;
    });
  }

  String? get _categoryFilterLabel {
    if (_categoryIdFilter == null) return null;
    for (final c in MockCategories.all) {
      if (c.id == _categoryIdFilter) return c.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Courses'),
        automaticallyImplyLeading: false,
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear'),
            ),
        ],
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
                onFilterTap: () async {
                  final result = await Navigator.of(context).pushNamed(
                    AppRoutes.adminCourseFilter,
                    arguments: AdminCourseFilterArgs(
                      status: _statusFilter,
                      categoryId: _categoryIdFilter,
                    ),
                  );
                  if (result is AdminCourseFilterArgs) {
                    setState(() {
                      _statusFilter = result.status;
                      _categoryIdFilter = result.categoryId;
                    });
                  }
                },
              ),
            ),
            if (_hasActiveFilters) _filterChips(),
            Expanded(
              child: list.isEmpty
                  ? const AppEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No courses found',
                message:
                'Try a different search or clear your filters.',
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final c = list[i];
                  return AdminCourseCard(
                    course: c,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.adminCourseDetails,
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

  Widget _filterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          if (_statusFilter != null)
            _filterChip(
              label: _statusFilter!.label,
              onRemove: () => setState(() => _statusFilter = null),
            ),
          if (_categoryFilterLabel != null)
            _filterChip(
              label: _categoryFilterLabel!,
              onRemove: () => setState(() => _categoryIdFilter = null),
            ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}