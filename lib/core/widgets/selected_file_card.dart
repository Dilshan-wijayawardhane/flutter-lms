import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Compact card representing a single selected file (name, size, remove).
/// Complements FilePickerField and UploadPreview for list contexts.
class SelectedFileCard extends StatelessWidget {
  const SelectedFileCard({
    super.key,
    required this.fileName,
    this.fileSizeLabel,
    this.icon = Icons.insert_drive_file_outlined,
    this.onRemove,
    this.onTap,
  });

  final String fileName;
  final String? fileSizeLabel;
  final IconData icon;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (fileSizeLabel != null)
                      Text(fileSizeLabel!, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  iconSize: 18,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}