import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../mock_data/models/mock_course.dart';

/// Course card variant used by the instructor course list.
/// Shows status, title, learners, rating, and lesson count.
class InstructorCourseCard extends StatelessWidget {
  const InstructorCourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  final MockCourse course;
  final VoidCallback? onTap;

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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: AppTextStyles.headingSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _statusChip(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.categoryName,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 6),
                    _metaRow(),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        height: 72,
        width: 72,
        child: (course.thumbnailUrl != null &&
            course.thumbnailUrl!.isNotEmpty)
            ? Image.network(
          course.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbPlaceholder(),
        )
            : _thumbPlaceholder(),
      ),
    );
  }

  Widget _thumbPlaceholder() => Container(
    color: AppColors.primarySurface,
    child: const Icon(
      Icons.play_circle_outline_rounded,
      size: 30,
      color: AppColors.primary,
    ),
  );

  Widget _statusChip() {
    switch (course.status) {
      case CourseStatus.draft:
        return const AppStatusChip(status: AppStatus.draft);
      case CourseStatus.published:
        return const AppStatusChip(status: AppStatus.published);
      case CourseStatus.archived:
        return const AppStatusChip(status: AppStatus.archived);
    }
  }

  Widget _metaRow() {
    return Row(
      children: [
        const Icon(Icons.people_alt_outlined,
            size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 2),
        Text('${course.learnerCount}', style: AppTextStyles.caption),
        const SizedBox(width: AppSpacing.sm),
        const Icon(Icons.star_rounded,
            size: 14, color: AppColors.star),
        const SizedBox(width: 2),
        Text(course.rating.toStringAsFixed(1),
            style: AppTextStyles.caption),
        const SizedBox(width: AppSpacing.sm),
        const Icon(Icons.menu_book_outlined,
            size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 2),
        Text('${course.lessonCount} lessons',
            style: AppTextStyles.caption),
      ],
    );
  }
}