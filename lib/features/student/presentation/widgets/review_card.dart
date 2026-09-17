import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../data/models/review.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.isOwn = false,
    this.onEdit,
    this.onDelete,
  });

  final CourseReview review;
  final bool isOwn;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
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
              AppAvatar(name: review.studentName, size: 32),
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
                      Formatters.relative(review.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (isOwn && onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  iconSize: 18,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                ),
              if (isOwn && onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  iconSize: 18,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                  tooltip: 'Delete',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 16,
                color: AppColors.star,
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(review.comment, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}