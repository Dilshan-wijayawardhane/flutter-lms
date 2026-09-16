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
import '../../../student/data/models/enrollment.dart';
import '../../providers/instructor_course_provider.dart';
import '../../providers/instructor_learner_provider.dart';
import '../widgets/learner_card.dart';

class InstructorEnrollmentsPage extends StatefulWidget {
  const InstructorEnrollmentsPage({super.key, this.courseId});

  final String? courseId;

  @override
  State<InstructorEnrollmentsPage> createState() =>
      _InstructorEnrollmentsPageState();
}

class _InstructorEnrollmentsPageState
    extends State<InstructorEnrollmentsPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _filter = 0; // 0=All, 1=In Progress, 2=Completed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courses = context.read<InstructorCourseProvider>();
      if (courses.listState != LoadState.success) {
        courses.loadMyCourses();
      }
      final id = widget.courseId ?? _firstCourseId();
      if (id != null) {
        context.read<InstructorLearnerProvider>().loadEnrollments(id);
      }
    });
  }

  String? _firstCourseId() {
    final list = context.read<InstructorCourseProvider>().courses;
    return list.isEmpty ? null : list.first.id;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Enrollment> _filtered(List<Enrollment> all) {
    return all.where((e) {
      final matchesQuery = _query.isEmpty ||
          (e.studentName ?? e.studentId)
              .toLowerCase()
              .contains(_query.toLowerCase()) ||
          e.courseName.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = switch (_filter) {
        1 => e.status == EnrollmentStatus.active,
        2 => e.status == EnrollmentStatus.completed,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorLearnerProvider>();
    final courses = context.watch<InstructorCourseProvider>().courses;
    final courseId = widget.courseId ??
        (courses.isEmpty ? null : courses.first.id);

    // Trigger loading when courseId is available and we haven't loaded yet.
    if (courseId != null &&
        p.enrollStateFor(courseId) == LoadState.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        p.loadEnrollments(courseId);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learners'),
        automaticallyImplyLeading: widget.courseId != null,
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
                _chip('In Progress', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Completed', 2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: courseId == null
            ? const AppEmptyState(
          icon: Icons.people_alt_outlined,
          title: 'No courses yet',
          message: 'Create a course to see learners here.',
        )
            : Column(
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
                hint: 'Search learners or courses',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(child: _body(p, courseId)),
          ],
        ),
      ),
    );
  }

  Widget _body(InstructorLearnerProvider p, String courseId) {
    final state = p.enrollStateFor(courseId);
    final all = p.enrollmentsFor(courseId);

    if (state == LoadState.loading && all.isEmpty) {
      return const AppLoading(message: 'Loading learners…');
    }
    if (state == LoadState.error && all.isEmpty) {
      return AppErrorState(
        title: 'Could not load learners',
        message: p.enrollErrorFor(courseId) ?? 'Please try again.',
        onRetry: () => p.loadEnrollments(courseId, force: true),
      );
    }

    final list = _filtered(all);
    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.people_alt_outlined,
        title: 'No learners found',
        message: 'Try a different search or filter to see enrollments.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => p.loadEnrollments(courseId, force: true),
      child: ListView.separated(
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
          final e = list[i];
          return LearnerCard(
            enrollment: e,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.instructorLearnerDetails,
              arguments: e.id,
            ),
          );
        },
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