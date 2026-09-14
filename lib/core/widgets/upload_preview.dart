import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Preview tile for a media upload (image / video / document).
/// UI-only in Phase 1.
class UploadPreview extends StatelessWidget {
  const UploadPreview({
    super.key,
    required this.fileName,
    required this.fileTypeLabel,
    this.fileSizeLabel,
    this.thumbnailUrl,
    this.progress,
    this.onRemove,
  });

  final String fileName;
  final String fileTypeLabel; // "IMAGE", "VIDEO", "DOCUMENT"
  final String? fileSizeLabel;
  final String? thumbnailUrl;
  final double? progress; // 0..1 while uploading (Phase 2)
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _thumbnail(),
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius:
                        BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text(
                        fileTypeLabel,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    if (fileSizeLabel != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(fileSizeLabel!, style: AppTextStyles.caption),
                    ],
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.danger,
              ),
            ),
        ],
      ),
    );
  }

  Widget _thumbnail() {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Image.network(
          thumbnailUrl!,
          height: 44,
          width: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    height: 44,
    width: 44,
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    ),
    child: const Icon(
      Icons.cloud_upload_outlined,
      color: AppColors.primary,
    ),
  );
}