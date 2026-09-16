import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../student/data/models/review.dart';
import '../../providers/instructor_learner_provider.dart';

class InstructorReviewsPage extends StatefulWidget {
  const InstructorReviewsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorReviewsPage> createState() =>
      _InstructorReviewsPageState();
}

class _InstructorReviewsPageState extends State<InstructorReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InstructorLearnerProvider>()
          .loadReviews(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorLearnerProvider>();
    final state = p.reviewsStateFor(widget.courseId);
    final reviews = p.reviewsFor(widget.courseId);

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
          message: 'Please try again.',
          onRetry: () => p.loadReviews(widget.courseId,
              force: true),
        )
            : reviews.isEmpty
            ? const AppEmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          message:
          'Reviews from your students will appear here.',
        )
            : RefreshIndicator(
          onRefresh: () => p.loadReviews(
            widget.courseId,
            force: true,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: reviews.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) =>
                _reviewCard(reviews[i]),
          ),
        ),
      ),
    );
  }

  Widget _reviewCard(CourseReview r) {
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
                    Text(
                      Formatters.relative(r.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
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