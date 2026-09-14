import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_reviews.dart';
import '../../../../mock_data/models/mock_review.dart';

class InstructorReviewsPage extends StatefulWidget {
  const InstructorReviewsPage({super.key, this.courseId});

  final String? courseId;

  @override
  State<InstructorReviewsPage> createState() =>
      _InstructorReviewsPageState();
}

class _InstructorReviewsPageState extends State<InstructorReviewsPage> {
  late List<MockReview> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = widget.courseId == null
        ? List.of(MockReviews.all)
        : List.of(MockReviews.byCourse(widget.courseId!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reviews')),
      body: SafeArea(
        top: false,
        child: _reviews.isEmpty
            ? const AppEmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          message:
          'Reviews from your students will appear here.',
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _reviews.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _reviewCard(_reviews[i]),
        ),
      ),
    );
  }

  Widget _reviewCard(MockReview r) {
    final hidden = r.visibility == ReviewVisibility.hidden;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: hidden ? AppColors.border : AppColors.border,
        ),
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
                      '${r.courseName} · ${Formatters.relative(r.createdAt)}',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hidden)
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
                onPressed: () {
                  AppSnackbar.showInfo(
                    context,
                    'Reply will arrive with backend integration.',
                  );
                },
                icon: const Icon(Icons.reply_rounded, size: 18),
                label: const Text('Reply'),
              ),
              const Spacer(),
              Text(
                hidden ? 'Hidden from students' : 'Visible to students',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}