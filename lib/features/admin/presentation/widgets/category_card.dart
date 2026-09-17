import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../student/data/models/category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onToggleActive,
  });

  final CourseCategory category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;

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
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${category.courseCount} courses',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (category.isActive)
                    const AppStatusChip(status: AppStatus.active)
                  else
                    const AppStatusChip(status: AppStatus.inactive),
                ],
              ),
              if (category.description != null &&
                  category.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  category.description!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  if (onToggleActive != null)
                    TextButton.icon(
                      onPressed: onToggleActive,
                      icon: Icon(
                        category.isActive
                            ? Icons.toggle_off_outlined
                            : Icons.toggle_on_outlined,
                        size: 20,
                      ),
                      label: Text(
                        category.isActive ? 'Deactivate' : 'Activate',
                      ),
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