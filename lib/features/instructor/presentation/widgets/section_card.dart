import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../student/data/models/section.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final CourseSection section;
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
          padding: const EdgeInsets.all(AppSpacing.md),
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
                  color: AppColors.primarySurface,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '${section.order}',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      section.description?.isNotEmpty == true
                          ? section.description!
                          : '${section.lessonCount} lessons',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}