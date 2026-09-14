import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// UI-only image picker field.
///
/// Does NOT use image_picker yet. Displays a placeholder / preview and
/// calls [onPickRequested] when tapped. In Phase 2 this will open the real
/// image picker and pass the selected file back.
class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    this.imageUrl,
    this.localPreviewPath,
    this.onPickRequested,
    this.onRemove,
    this.label = 'Select image',
    this.height = 160,
  });

  final String? imageUrl;
  final String? localPreviewPath;
  final VoidCallback? onPickRequested;
  final VoidCallback? onRemove;
  final String label;
  final double height;

  bool get _hasImage =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
          (localPreviewPath != null && localPreviewPath!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPickRequested,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _hasImage
                ? (localPreviewPath != null
                ? Image.asset(
              localPreviewPath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _emptyState(),
            )
                : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _emptyState(),
            ))
                : _emptyState(),
          ),
        ),
        if (_hasImage && onRemove != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _emptyState() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(
        Icons.add_photo_alternate_outlined,
        size: 36,
        color: AppColors.textTertiary,
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(label, style: AppTextStyles.bodySmall),
      const SizedBox(height: 2),
      Text(
        'PNG, JPG up to 5MB',
        style: AppTextStyles.caption,
      ),
    ],
  );
}