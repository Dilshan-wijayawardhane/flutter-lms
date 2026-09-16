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
import '../../../../core/widgets/app_success_message.dart';
import '../../data/models/review.dart';
import '../../providers/profile_provider.dart';
import '../../providers/review_provider.dart';

class StudentReviewsPage extends StatefulWidget {
  const StudentReviewsPage({super.key, this.courseId});

  final String? courseId;

  @override
  State<StudentReviewsPage> createState() => _StudentReviewsPageState();
}

class _StudentReviewsPageState extends State<StudentReviewsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<ReviewProvider>()
            .loadForCourse(widget.courseId!);
      });
    }
  }

  Future<void> _delete(CourseReview review) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete review?',
      message: 'This will permanently remove your review.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    final ok = await context
        .read<ReviewProvider>()
        .delete(courseId: review.courseId, reviewId: review.id);

    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Review deleted.');
    } else {
      AppSnackbar.showError(context, 'Could not delete review.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseId = widget.courseId;
    if (courseId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Reviews')),
        body: const AppEmptyState(
          icon: Icons.rate_review_outlined,
          title: 'Open a course to see reviews',
          message: 'Reviews are shown per course.',
        ),
      );
    }

    final provider = context.watch<ReviewProvider>();
    final state = provider.stateFor(courseId);
    final reviews = provider.reviewsFor(courseId);
    final myId = context.watch<ProfileProvider>().profile?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reviews')),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading && reviews.isEmpty
            ? const AppLoading(message: 'Loading reviews…')
            : state == LoadState.error && reviews.isEmpty
            ? AppErrorState(
          title: 'Could not load reviews',
          message:
          provider.errorFor(courseId) ?? 'Please try again.',
          onRetry: () => provider.loadForCourse(courseId,
              force: true),
        )
            : reviews.isEmpty
            ? const AppEmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          message:
          'Be the first to review this course.',
        )
            : RefreshIndicator(
          onRefresh: () => provider.loadForCourse(courseId,
              force: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: reviews.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) => _reviewCard(
              reviews[i],
              isOwn: myId != null &&
                  reviews[i].studentId == myId,
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewCard(CourseReview r, {required bool isOwn}) {
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
              AppAvatar(name: r.studentName, size: 32),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.studentName,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.relative(r.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (isOwn)
                IconButton(
                  onPressed: () => _delete(r),
                  iconSize: 18,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                  tooltip: 'Delete',
                ),
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
        ],
      ),
    );
  }
}