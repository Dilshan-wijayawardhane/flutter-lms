import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/media_picker.dart';

/// Image picker field.
///
/// Supports BOTH APIs during transition:
/// - [onPickRequested] — legacy callback (fires when tapped; no picker used)
/// - [onPicked] — new callback that fires with a real picked file
class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    this.imageUrl,
    this.localFilePath,
    this.localPreviewPath, // legacy alias
    this.onPickRequested, // legacy callback
    this.onPicked, // new callback
    this.onRemove,
    this.onUpload,
    this.uploadProgress,
    this.label = 'Select image',
    this.height = 160,
  });

  final String? imageUrl;
  final String? localFilePath;
  final String? localPreviewPath;
  final VoidCallback? onPickRequested;
  final ValueChanged<PickedMedia>? onPicked;
  final VoidCallback? onRemove;
  final VoidCallback? onUpload;
  final double? uploadProgress;
  final String label;
  final double height;

  String? get _previewPath => localFilePath ?? localPreviewPath;

  bool get _hasImage =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
          (_previewPath != null && _previewPath!.isNotEmpty);

  Future<void> _handlePick() async {
    // If a legacy handler is set, call it directly (existing pages).
    if (onPicked == null) {
      onPickRequested?.call();
      return;
    }
    final picked = await MediaPicker.pickImage();
    if (picked == null) return;
    onPicked!(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _handlePick,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _hasImage ? _preview() : _emptyState(),
          ),
        ),
        if (uploadProgress != null) ...[
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: uploadProgress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
        if (_hasImage) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onUpload != null)
                TextButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Upload'),
                ),
              if (onRemove != null)
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  label: const Text('Remove'),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _preview() {
    final path = _previewPath;
    if (path != null && path.isNotEmpty) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _emptyState(),
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
      Text('PNG, JPG up to 5MB', style: AppTextStyles.caption),
    ],
  );
}