import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/data/models/review.dart';
import '../../../student/providers/instructor_course_provider.dart';
import '../../providers/admin_review_provider.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courses = context.read<InstructorCourseProvider>();
      if (courses.listState != LoadState.success) {
        courses.loadMyCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<InstructorCourseProvider>().courses;
    final courseId = courses.isEmpty ? null : courses.first.id;
    final p = context.watch<AdminReviewProvider>();

    if (courseId != null && p.state == LoadState.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        p.load(courseId);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reviews'),
        automaticallyImplyLeading: false,
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
                _chip('Visible', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Hidden', 2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: courseId == null
            ? const AppEmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No courses yet',
          message: 'Reviews will appear once courses exist.',
        )
            : _body(p, courseId),
      ),
    );
  }

  Widget _body(AdminReviewProvider p, String courseId) {
    if (p.state == LoadState.loading && p.reviews.isEmpty) {
      return const AppLoading(message: 'Loading reviews…');
    }
    if (p.state == LoadState.error && p.reviews.isEmpty) {
      return AppErrorState(
        title: 'Could not load reviews',
        message: p.errorMessage ?? 'Please try again.',
        onRetry: () => p.load(courseId, force: true),
      );
    }

    final list = _tab == 0
        ? p.reviews
        : _tab == 1
        ? p.reviews.where((r) => r.isVisible).toList()
        : p.reviews.where((r) => !r.isVisible).toList();

    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.rate_review_outlined,
        title: 'No reviews',
        message: 'Reviews will appear as students rate courses.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => p.load(courseId, force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _card(p, list[i]),
      ),
    );
  }

  Widget _card(AdminReviewProvider p, CourseReview r) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: r.studentName, size: 36),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.studentName,
                        style: AppTextStyles.labelLarge),
                    const SizedBox(height: 2),
                    Text(r.courseName,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (r.isVisible)
                const AppStatusChip(status: AppStatus.active)
              else
                const AppStatusChip(status: AppStatus.inactive),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              5,
                  (i) => Icon(
                i < r.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 16,
                color: AppColors.star,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(r.comment, style: AppTextStyles.bodySmall),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _toggleVisibility(p, r),
                icon: Icon(
                  r.isVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                ),
                label: Text(r.isVisible ? 'Hide' : 'Show'),
              ),
              const Spacer(),
              Text(
                Formatters.relative(r.createdAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVisibility(
      AdminReviewProvider p,
      CourseReview r,
      ) async {
    final action = r.isVisible ? 'Hide' : 'Show';
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: '$action review?',
      message: r.isVisible
          ? 'The review will be hidden from the course page.'
          : 'The review will become visible on the course page.',
      confirmLabel: action,
      isDestructive: r.isVisible,
      icon: r.isVisible
          ? Icons.visibility_off_rounded
          : Icons.visibility_rounded,
    );
    if (!confirmed || !mounted) return;
    p.toggleVisibility(r.id);
    AppSnackbar.showSuccess(context, '$action successful.');
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