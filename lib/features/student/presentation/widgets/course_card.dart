import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../mock_data/models/mock_course.dart';

/// Compact list-style course card. Shows thumbnail, title, instructor,
/// rating, learners, and optional progress bar for enrolled courses.
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.showProgress = false,
    this.compact = false,
  });

  final MockCourse course;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumbnail(),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: AppTextStyles.headingSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _instructorRow(),
                    const SizedBox(height: 6),
                    _metaRow(),
                    if (showProgress) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _progressBar(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final size = compact ? 64.0 : 88.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        height: size,
        width: size,
        child: (course.thumbnailUrl != null &&
            course.thumbnailUrl!.isNotEmpty)
            ? Image.network(
          course.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbnailPlaceholder(),
        )
            : _thumbnailPlaceholder(),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppColors.primarySurface,
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 32,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _instructorRow() {
    return Row(
      children: [
        AppAvatar(
          name: course.instructorName,
          size: 20,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            course.instructorName,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        const Icon(Icons.star_rounded,
            size: 14, color: AppColors.star),
        const SizedBox(width: 2),
        Text(
          course.rating.toStringAsFixed(1),
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(width: 2),
        Text(
          '(${course.ratingCount})',
          style: AppTextStyles.caption,
        ),
        const SizedBox(width: AppSpacing.sm),
        const Icon(Icons.people_alt_outlined,
            size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 2),
        Text(_learnerLabel, style: AppTextStyles.caption),
      ],
    );
  }

  String get _learnerLabel {
    final n = course.learnerCount;
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }

  Widget _progressBar() {
    final value = (course.progressPercent / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(AppSpacing.radiusPill),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${course.progressPercent}%',
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}