import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../student/data/models/review.dart';

class ReviewModerationCard extends StatelessWidget {
  const ReviewModerationCard({
    super.key,
    required this.review,
    this.onHide,
    this.onShow,
    this.onTap,
  });

  final CourseReview review;
  final VoidCallback? onHide;
  final VoidCallback? onShow;
  final VoidCallback? onTap;

  bool get _isHidden => !review.isVisible;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(name: review.studentName, size: 36),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.studentName,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          review.courseName,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_isHidden)
                    const AppStatusChip(status: AppStatus.inactive)
                  else
                    const AppStatusChip(status: AppStatus.active),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  ...List.generate(
                    5,
                        (i) => Icon(
                      i < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: AppColors.star,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    Formatters.relative(review.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(review.comment, style: AppTextStyles.bodySmall),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  if (_isHidden)
                    TextButton.icon(
                      onPressed: onShow,
                      icon: const Icon(Icons.visibility_rounded,
                          size: 18),
                      label: const Text('Show'),
                    )
                  else
                    TextButton.icon(
                      onPressed: onHide,
                      icon: const Icon(Icons.visibility_off_rounded,
                          size: 18),
                      label: const Text('Hide'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}