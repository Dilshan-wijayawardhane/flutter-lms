import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/lesson.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.index,
    this.isCurrent = false,
    this.onTap,
  });

  final Lesson lesson;
  final int index;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = lesson.isLocked;
    final completed = lesson.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: locked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primarySurface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isCurrent ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: locked
                      ? AppColors.surfaceVariant
                      : completed
                      ? AppColors.success
                      .withValues(alpha: 0.12)
                      : AppColors.primarySurface,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  '$index',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: locked
                        ? AppColors.textTertiary
                        : completed
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lesson.type.name.toUpperCase()} · '
                          '${Formatters.duration(lesson.durationMinutes)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (locked)
                const Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppColors.textTertiary)
              else if (completed)
                const Icon(Icons.check_circle_rounded,
                    size: 20, color: AppColors.success)
              else
                const Icon(Icons.play_circle_outline_rounded,
                    size: 20, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}