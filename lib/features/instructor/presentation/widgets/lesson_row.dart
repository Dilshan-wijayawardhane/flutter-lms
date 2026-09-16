import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../student/data/models/lesson.dart';

class InstructorLessonRow extends StatelessWidget {
  const InstructorLessonRow({
    super.key,
    required this.lesson,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Lesson lesson;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _typeColor(lesson.type).withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(_typeIcon(lesson.type),
                    size: 20, color: _typeColor(lesson.type)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: AppTextStyles.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _statusChip(lesson.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(lesson.type.name.toUpperCase(),
                            style: AppTextStyles.caption),
                        const SizedBox(width: AppSpacing.xs),
                        Text('·', style: AppTextStyles.caption),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          Formatters.duration(lesson.durationMinutes),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.danger),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(LessonStatus status) {
    switch (status) {
      case LessonStatus.draft:
        return const AppStatusChip(status: AppStatus.draft, dense: true);
      case LessonStatus.published:
        return const AppStatusChip(
            status: AppStatus.published, dense: true);
    }
  }

  IconData _typeIcon(LessonType t) {
    switch (t) {
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.video:
        return Icons.play_circle_outline_rounded;
      case LessonType.document:
        return Icons.description_outlined;
    }
  }

  Color _typeColor(LessonType t) {
    switch (t) {
      case LessonType.text:
        return AppColors.info;
      case LessonType.video:
        return AppColors.primary;
      case LessonType.document:
        return AppColors.warning;
    }
  }
}