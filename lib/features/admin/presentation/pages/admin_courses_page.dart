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
import '../../../../core/widgets/app_search_bar.dart';
import '../../../student/data/models/course.dart';
import '../../providers/admin_course_provider.dart';
import '../widgets/admin_course_card.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminCourseProvider>();
      if (p.state != LoadState.success) p.load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminCourseProvider>();
    final hasFilters = p.statusFilter != null || p.categoryFilter != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Courses'),
        automaticallyImplyLeading: false,
        actions: [
          if (hasFilters)
            TextButton(
              onPressed: p.clearFilters,
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
                onChanged: (v) => p.setSearch(v),
                onFilterTap: () async {
                  final result = await Navigator.of(context).pushNamed(
                    AppRoutes.adminCourseFilter,
                    arguments: AdminCourseFilterArgs(
                      status: p.statusFilter,
                      categoryId: p.categoryFilter,
                    ),
                  );
                  if (result is AdminCourseFilterArgs) {
                    await p.setFilters(
                      status: result.status,
                      categoryId: result.categoryId,
                    );
                  }
                },
              ),
            ),
            if (hasFilters) _filterChips(p),
            Expanded(child: _body(p)),
          ],
        ),
      ),
    );
  }

  Widget _body(AdminCourseProvider p) {
    if (p.state == LoadState.loading && p.courses.isEmpty) {
      return const AppLoading(message: 'Loading courses…');
    }
    if (p.state == LoadState.error && p.courses.isEmpty) {
      return AppErrorState(
        title: 'Could not load courses',
        message: p.errorMessage ?? 'Please try again.',
        onRetry: () => p.load(force: true),
      );
    }
    if (p.courses.isEmpty) {
      return const AppEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'No courses found',
        message: 'Try a different search or clear your filters.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => p.load(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        itemCount: p.courses.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final c = p.courses[i];
          return AdminCourseCard(
            course: c,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.adminCourseDetails,
              arguments: c.id,
            ),
          );
        },
      ),
    );
  }

  Widget _filterChips(AdminCourseProvider p) {
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
          if (p.statusFilter != null)
            _chip(p.statusFilter!.name.toUpperCase(),
                    () => p.setFilters(categoryId: p.categoryFilter)),
          if (p.categoryFilter != null)
            _chip(p.categoryFilter!,
                    () => p.setFilters(status: p.statusFilter)),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onRemove) {
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